import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:displaying_images/logic/helper_functions.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/models/decrypt_to_gallery_vars.dart';
import 'package:displaying_images/logic/models/encrypt_image_wrapper.dart';
import 'package:displaying_images/logic/models/encrypt_isolate_vars.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:displaying_images/logic/viewstates/encryption_dialog_state.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:displaying_images/logic/viewstates/viewstate.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImagesController extends GetxController {
  final DisplayingImagesUseCase _useCase;
  final DisplayingImagesController _controller;

  final Rx<EncryptionDialogState> encryptionState =
      EncryptionDialogState.initial().obs;

  ReceivePort? encryptImagesIsolatePort;
  ReceivePort? decryptToGalleryIsolatePort;
  ReceivePort? decryptToMemoryIsolatePort;

  late final Function() showEncryptionStateDialog;
  late final Function() showSelectShareMethodeDialog;
  late final Function() showDecryptingImagesToShareDialog;
  late final Function() showSelectReceivingMethodeDialog;

  ImagesController(this._controller, this._useCase);

  Future encryptImages(List<EncryptImageWrapper> imagesToEncrypt) async {
    print("koko encrypt > " + imagesToEncrypt.length.toString());
    var files = List<FileWrapper>.from(_controller.viewState.value.files);
    List<String> ids = [];

    for (var i = 0; i < imagesToEncrypt.length; i++) {
      var imageFile =
          await _useCase.createImageFile(_controller.currentPath.value);
      imagesToEncrypt[i] = imagesToEncrypt[i].copyWith(file: imageFile);
      ids.add(imagesToEncrypt[i].id);

      files.add(FileWrapper(
          file: imageFile, thumbUint8list: imagesToEncrypt[i].thumbnail));
    }
    _controller.viewState.value =
        _controller.viewState.value.copy(files: files);

    showEncryptionStateDialog();
    encryptionState.value = encryptionState.value.copy(
        encryptionLoading: true,
        encryptionLoadingMessage: "Encrypting images...",
        encryptionError: "",
        encryptionSuccessMessage: "",
        encryptionSuccess: false,
        encryptionProgress: 0);

    encryptImagesIsolatePort = ReceivePort();
    print("koko > start encrypt isolate");

    print("koko current isolate > " + Isolate.current.debugName.toString());
    var dir = await getExternalStorageDirectory();
    var s = await Isolate.spawn<EncryptIsolateVars>(
        encryptFilesIsolate,
        EncryptIsolateVars(
            isolateStatePort: encryptImagesIsolatePort!.sendPort,
            images: imagesToEncrypt,
            useCase: _useCase,
            osDir: dir!.path,
            path: _controller.currentPath.value,
            key: _controller.encryptionKey));
    s.kill();
    print("koko > end encrypt isolate");
    print("koko current isolate > " + Isolate.current.debugName.toString());

    var result = await encryptImagesIsolatePort!.first;
    encryptImagesIsolatePort!.close();
    encryptImagesIsolatePort = null;

    if (result is DataException) {
      encryptionState.value = encryptionState.value.copy(
          encryptionLoading: false,
          encryptionLoadingMessage: "",
          encryptionSuccessMessage: "",
          encryptionError: result.code,
          encryptionSuccess: false,
          encryptionProgress: 0);
    } else {
      List<List<Uint8List>> encryptedResults = result as List<List<Uint8List>>;
      var finished = 0;
      for (var i = 0; i < imagesToEncrypt.length; i++) {
        await _useCase.saveEncryptedImage(imagesToEncrypt[i].file!,
            encryptedResults[i][0], encryptedResults[i][1], dir!.path);
        await deletePhysicalFile(imagesToEncrypt[i].imageApsolutePath);
        finished += 1;
        encryptionState.value = encryptionState.value.copy(
            encryptionLoading: true,
            encryptionError: "",
            encryptionSuccess: false,
            encryptionProgress: finished / imagesToEncrypt.length);
      }
      await PhotoManager.editor.deleteWithIds(ids);

      encryptionState.value = encryptionState.value.copy(
          encryptionLoading: false,
          encryptionError: "",
          encryptionSuccess: true,
          encryptionSuccessMessage: "Encryption done successfully!",
          encryptionProgress: 1);
      // await Future.wait(deleteOriginalImageTasks.map((e) async => await e()));
      // await Future.wait(saveEncryptedImagesTasks.map((e) => e()));
    }
  }

  decryptImagesToGallery() async {
    if (_controller.selectionViewState.value.isSelectingFolders) {
      return;
    }

    showEncryptionStateDialog();
    encryptionState.value = encryptionState.value.copy(
        encryptionLoading: true,
        encryptionLoadingMessage: "Decrypting images...",
        encryptionError: "",
        encryptionSuccessMessage: "",
        encryptionSuccess: false,
        encryptionProgress: 0);

    if (_controller.selectionViewState.value.selectedFiles.length >
        MAX_DECRYPT_IMAGES) {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false,
          error: DisplayImagesErrorCodes.exceededMaxDecryptNum.toString());
      return;
    }

    List<F.File> imageFiles = [];

    Map<int, FileWrapper> files = {
      for (var e = 0; e < _controller.viewState.value.files.length; e++)
        e: _controller.viewState.value.files[e]
    };
    for (var selected
        in _controller.selectionViewState.value.selectedFiles.keys) {
      imageFiles.add(_controller.viewState.value.files[selected].file);
      files.remove(selected);
    }

    var dir = await getExternalStorageDirectory();
    decryptToGalleryIsolatePort = ReceivePort();
    await Isolate.spawn<DecryptToGalleryVars>(
        decryptImageIsolate,
        DecryptToGalleryVars(
            isolateStatePort: decryptToGalleryIsolatePort!.sendPort,
            files: imageFiles,
            useCase: _useCase,
            osDir: dir!.path,
            key: _controller.encryptionKey));
    var result = await decryptToGalleryIsolatePort!.first;
    decryptToGalleryIsolatePort!.close();
    decryptToGalleryIsolatePort = null;

    if (result is DataException) {
      encryptionState.value = encryptionState.value.copy(
          encryptionLoading: false,
          encryptionLoadingMessage: "",
          encryptionSuccessMessage: "",
          encryptionError: result.code,
          encryptionSuccess: false,
          encryptionProgress: 0);
    } else {
      List<Uint8List> decryptedResults = result as List<Uint8List>;
      var finished = 0;
      for (var i = 0; i < imageFiles.length; i++) {
        await _useCase.decryptImagesBackToGallery(
            imageFiles[i], decryptedResults[i]);
        finished += 1;
        encryptionState.value = encryptionState.value.copy(
            encryptionLoading: true,
            encryptionError: "",
            encryptionSuccess: false,
            encryptionProgress: finished / imageFiles.length);
      }

      encryptionState.value = encryptionState.value.copy(
          encryptionLoading: false,
          encryptionError: "",
          encryptionSuccess: true,
          encryptionSuccessMessage: "Decryption done successfully!",
          encryptionProgress: 1);
    }

    _controller.selectionViewState.value = _controller.selectionViewState.value
        .copy(
            selectedFiles: {},
            isSelectingImages: false,
            isSelectingFolders: false);

    _controller.viewState.value =
        _controller.viewState.value.copy(files: files.values.toList());
  }

  shareImages() async {
    if (_controller.selectionViewState.value.isSelectingFolders) {
      return;
    }

    _controller.showStateDialog();
    _controller.dialogState.value = _controller.dialogState.value
        .copy(loading: true, error: "", doneMessage: "", isDone: false);

    List<FileWrapper> selectedImages = [];
    for (var selected
        in _controller.selectionViewState.value.selectedFiles.keys) {
      selectedImages.add(_controller.viewState.value.files[selected]);
    }

    var result = await _useCase.shareEncryptedImages(
        selectedImages, _controller.currentPath.value);

    if (result is DataException) {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false, isDone: false, doneMessage: "", error: result.code);
    } else {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false,
          doneMessage: "Sharing files done successfully",
          isDone: true,
          error: "");
    }
  }

  Future<List<Uint8List>> getSelectedImages() async {
    List<F.File> selectedImages = [];
    for (var selected
        in _controller.selectionViewState.value.selectedFiles.keys) {
      selectedImages.add(_controller.viewState.value.files[selected].file);
    }

    var dir = await getExternalStorageDirectory();
    decryptToGalleryIsolatePort = ReceivePort();
    await Isolate.spawn<DecryptToGalleryVars>(
        decryptImageIsolate,
        DecryptToGalleryVars(
            isolateStatePort: decryptToGalleryIsolatePort!.sendPort,
            files: selectedImages,
            useCase: _useCase,
            osDir: dir!.path,
            key: _controller.encryptionKey));
    var result = await decryptToGalleryIsolatePort!.first as List<Uint8List>;
    decryptToGalleryIsolatePort!.close();
    decryptToGalleryIsolatePort = null;
    return result;
  }

  importZipedImages(List<File> zFiles) async {
    if (_controller.selectionViewState.value.isSelectingFolders ||
        _controller.selectionViewState.value.isSelectingImages) {
      return;
    }

    _controller.showStateDialog();
    _controller.dialogState.value = _controller.dialogState.value
        .copy(loading: true, error: "", doneMessage: "", isDone: false);

    // create list of extact files task
    List<Future<dynamic>> extractFilesTasks = zFiles
        .map((zFile) => _useCase.importEncryptedImages(
            zFile, _controller.currentPath.value, _controller.encryptionKey))
        .toList();
    var results = await Future.wait(extractFilesTasks);

    for (var result in results) {
      if (result is DataException) {
        _controller.dialogState.value = _controller.dialogState.value.copy(
            loading: false, isDone: false, doneMessage: "", error: result.code);
      } else if (result is List<FileWrapper>) {
        List<FileWrapper> files = List.from(_controller.viewState.value.files);
        files.addAll(List<FileWrapper>.from(result));

        _controller.viewState.value =
            _controller.viewState.value.copy(files: files);

        _controller.dialogState.value = _controller.dialogState.value.copy(
            loading: false,
            doneMessage: "Imported images done successfully",
            isDone: true,
            error: "");
      }
    }
  }
}
