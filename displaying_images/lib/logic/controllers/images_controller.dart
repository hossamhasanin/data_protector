import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
// ignore: library_prefixes
import 'package:base/datasource/File.dart' as F;
import 'package:displaying_images/displaying_images.dart';
import 'package:displaying_images/logic/controllers/decrypt_to_gallery_params.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/models/decrypt_to_gallery_vars.dart';
import 'package:displaying_images/logic/models/encrypt_image_wrapper.dart';
import 'package:displaying_images/logic/models/encrypt_isolate_vars.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_ui/progess_state_dialog/progress_dialog_state.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImagesController extends GetxController {
  final DisplayingImagesUseCase _useCase;
  final DisplayingImagesController _controller;

  final Rx<ProgressDialogState> encryptionState =
      ProgressDialogState.initial().obs;

  ReceivePort? encryptImagesIsolatePort;
  ReceivePort? decryptToGalleryIsolatePort;
  ReceivePort? decryptToMemoryIsolatePort;

  final CryptoManager _cryptoManager = Get.find();

  late final StreamSubscription<List> _decryptionIsolatesListener;

  final StreamController<DecryptToGalleryParams> _decryptToGalleryParams = StreamController();

  late final Function() showEncryptionStateDialog;
  late final Function() showSelectShareMethodeDialog;
  late final Function() showSelectReceivingMethodeDialog;

  ImagesController(this._controller, this._useCase);

  @override
  void onInit() {
    super.onInit();
    
    _listenToDeryptionIsolates();
  }
  

  @override
  void onClose() {
    _decryptionIsolatesListener.cancel();
    _decryptToGalleryParams.close();
    super.onClose();
  }

  Future encryptImages(List<EncryptImageWrapper> imagesToEncrypt) async {
    print("koko encrypt > " + imagesToEncrypt.length.toString());

    showEncryptionStateDialog();
    encryptionState.value = encryptionState.value.copy(
        loading: true,
        loadingMessage: "Encrypting images...",
        error: "",
        successMessage: "",
        success: false,
        progress: 0);

    var files = List<FileWrapper>.from(_controller.viewState.value.files);
    List<String> ids = [];

    for (var i = 0; i < imagesToEncrypt.length; i++) {
      var imageFile =
          await _useCase.createImageFile(_controller.currentPath.value);
      print("koko image file > " + imageFile.toString());
      imagesToEncrypt[i] = imagesToEncrypt[i].copyWith(file: imageFile);
      ids.add(imagesToEncrypt[i].id);

      files.add(FileWrapper(
          file: imageFile, thumbUint8list: imagesToEncrypt[i].thumbnail));
    }
    _controller.viewState.value =
        _controller.viewState.value.copy(files: files);

    

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
    // s.kill();
    print("koko > end encrypt isolate");
    print("koko current isolate > " + Isolate.current.debugName.toString());

    var result = await encryptImagesIsolatePort!.first;
    print("koko > end encrypt isolate port");
    encryptImagesIsolatePort!.close();
    encryptImagesIsolatePort = null;

    if (result is DataException) {
      encryptionState.value = encryptionState.value.copy(
          loading: false,
          loadingMessage: "",
          successMessage: "",
          error: result.code,
          success: false,
          progress: 1);
      // s.kill();
      print("error with encryption :" + result.toString());
      // return;
    } else {
      List<List> encryptedResults = result as List<List>;
      var finished = 0;
      for (var i = 0; i < imagesToEncrypt.length; i++) {
        await _useCase.saveEncryptedImage(imagesToEncrypt[i].file!, encryptedResults[i][0], encryptedResults[i][1], dir.path);
      print("encryption done successfully and saved images files");
        // await deletePhysicalFile(imagesToEncrypt[i].imageApsolutePath);
        // File(imagesToEncrypt[i].imageApsolutePath).deleteSync();
      // PhotoManager.editor.deleteWithIds([imagesToEncrypt[i].id]);
        print("encryption done successfully and deleted images files");
        finished += 1;
        encryptionState.value = encryptionState.value.copy(
            loading: true,
            error: "",
            success: false,
            progress: finished / imagesToEncrypt.length);
      }
      print("encryption done successfully completed");
      await PhotoManager.editor.deleteWithIds(ids);

      encryptionState.value = encryptionState.value.copy(
          loading: false,
          error: "",
          success: true,
          successMessage: "Encryption done successfully!",
          progress: 1);
      s.kill();
      // await Future.wait(deleteOriginalImageTasks.map((e) async => await e()));
      // await Future.wait(saveEncryptedImagesTasks.map((e) => e()));
    }
  }

  _listenToDeryptionIsolates() {
    int finishedImages = 0;
    int currentImage = 0;
    _decryptionIsolatesListener = zipTowStreams(_decryptToGalleryParams.stream, _cryptoManager.readyImageStream).listen((data) async {
      Uint8List image = data[1] as Uint8List;
      DecryptToGalleryParams params = data[0] as DecryptToGalleryParams;
      await _useCase.decryptImagesBackToGallery(
            params.imageFiles[currentImage], image);
        encryptionState.value = encryptionState.value.copy(
            loading: true,
            error: "",
            success: false,
            progress: finishedImages / params.imageFiles.length);

      currentImage += 1;
      finishedImages += 1;

      print("koko finished images > "+ finishedImages.toString());

      if (finishedImages == params.imageFiles.length) {
        encryptionState.value = encryptionState.value.copy(
          loading: false,
          error: "",
          success: true,
          successMessage: "Decryption done successfully!",
          progress: 1);

        _controller.selectionViewState.value = _controller.selectionViewState.value
            .copy(
                selectedFiles: {},
                isSelectingImages: false,
                isSelectingFolders: false);

        _controller.viewState.value =
            _controller.viewState.value.copy(files: params.filesAfterDecrypting.values.toList());
        
        currentImage = 0;
        finishedImages = 0;
      }
    });
  }

  Stream<List> zipTowStreams(Stream stream1, Stream stream2) async* {
    StreamIterator iterator1 = StreamIterator(stream1);
    StreamIterator iterator2 = StreamIterator(stream2);

    while (await iterator1.moveNext() && await iterator2.moveNext()){
      yield[iterator1.current, iterator2.current];
    }
  }

  decryptImagesToGallery() async {
    if (_controller.selectionViewState.value.isSelectingFolders) {
      return;
    }

    final isConfermed = await _controller.showConfirmDialog(
        "Are you sure you are going to decrypt images to gallery?");
    if (!isConfermed) {
      return;
    }

    showEncryptionStateDialog();
    encryptionState.value = encryptionState.value.copy(
        loading: true,
        loadingMessage: "Decrypting images...",
        error: "",
        successMessage: "",
        success: false,
        progress: 0);

    if (_controller.selectionViewState.value.selectedFiles.length >
        MAX_DECRYPT_IMAGES) {
      encryptionState.value = encryptionState.value.copy(
          loading: false,
          loadingMessage: "",
          error: DisplayImagesErrorCodes.exceededMaxDecryptNum.toString(),
          successMessage: "",
          success: false,
          progress: 0);
      return;
    }

    List<F.File> imageFiles = [];

    Map<int, FileWrapper> files = {
      for (var e = 0; e < _controller.viewState.value.files.length; e++)
        e: _controller.viewState.value.files[e]
    };

    await _cryptoManager.spawnIsolates();
    final vars = DecryptToGalleryParams(imageFiles: imageFiles, filesAfterDecrypting: files);
    
    for (var selected
        in _controller.selectionViewState.value.selectedFiles.keys) {
      final file  = _controller.viewState.value.files[selected].file;
      
      final encryptedParts = await CryptoManager.loadEncryptedParts(file.name, file.path);

      _cryptoManager.decryptImageWithLimitedIsolates(encryptedParts, _controller.encryptionKey);
      _decryptToGalleryParams.add(vars);

      imageFiles.add(file);
      files.remove(selected);
    }


    // var dir = await getExternalStorageDirectory();
    // decryptToGalleryIsolatePort = ReceivePort();
    // await Isolate.spawn<DecryptToGalleryVars>(
    //     decryptImageIsolate,
    //     DecryptToGalleryVars(
    //         isolateStatePort: decryptToGalleryIsolatePort!.sendPort,
    //         files: imageFiles,
    //         useCase: _useCase,
    //         osDir: dir!.path,
    //         key: _controller.encryptionKey));
    // var result = await decryptToGalleryIsolatePort!.first;
    // decryptToGalleryIsolatePort!.close();
    // decryptToGalleryIsolatePort = null;

    // if (result is DataException) {
    //   encryptionState.value = encryptionState.value.copy(
    //       loading: false,
    //       loadingMessage: "",
    //       successMessage: "",
    //       error: result.code,
    //       success: false,
    //       progress: 0);
    // } else {
    //   List<Uint8List> decryptedResults = result as List<Uint8List>;
    //   var finished = 0;
    //   for (var i = 0; i < imageFiles.length; i++) {
    //     await _useCase.decryptImagesBackToGallery(
    //         imageFiles[i], decryptedResults[i]);
    //     finished += 1;
    //     encryptionState.value = encryptionState.value.copy(
    //         loading: true,
    //         error: "",
    //         success: false,
    //         progress: finished / imageFiles.length);
    //   }

    //   encryptionState.value = encryptionState.value.copy(
    //       loading: false,
    //       error: "",
    //       success: true,
    //       successMessage: "Decryption done successfully!",
    //       progress: 1);
    // }

    // _controller.selectionViewState.value = _controller.selectionViewState.value
    //     .copy(
    //         selectedFiles: {},
    //         isSelectingImages: false,
    //         isSelectingFolders: false);

    // _controller.viewState.value =
    //     _controller.viewState.value.copy(files: files.values.toList());
  }

  shareImages() async {
    if (_controller.selectionViewState.value.isSelectingFolders) {
      return;
    }

    final isConfermed = await _controller.showConfirmDialog(
        "Are you sure you are going to share those images images?");
    if (!isConfermed) {
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

  getSelectedImages(Function(List<Uint8List>) actionWhenDone) async {
    List<F.File> selectedImages = [];

    final isConfermed = await _controller.showConfirmDialog(
        "Are you sure you are going to decrypt images and share them ?");
    if (!isConfermed) {
      return;
    }

    showEncryptionStateDialog();

    encryptionState.value = encryptionState.value.copy(
        loading: true,
        loadingMessage:
            "Wait I am decrypting these images for you , just a sec...",
        error: "",
        successMessage: "",
        success: false,
        progress: 0);

    if (_controller.selectionViewState.value.selectedFiles.length >
        MAX_DECRYPT_IMAGES) {
      encryptionState.value = encryptionState.value.copy(
          loading: false,
          loadingMessage: "",
          error: DisplayImagesErrorCodes.exceededMaxDecryptNum.toString(),
          successMessage: "",
          success: false,
          progress: 0);
      return [];
    }

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
    var result = await decryptToGalleryIsolatePort!.first;
    decryptToGalleryIsolatePort!.close();
    decryptToGalleryIsolatePort = null;

    if (result is DataException) {
      encryptionState.value = encryptionState.value.copy(
          loading: false,
          loadingMessage: "",
          successMessage: "",
          error: result.code,
          success: false,
          progress: 0);
    } else {
      List<Uint8List> decryptedResults = result as List<Uint8List>;
      encryptionState.value = encryptionState.value.copy(
          loading: false,
          error: "",
          success: true,
          successMessage:
              "Decryption done successfully , now I will take you to the send those images!",
          actionWhenDone: () {
            actionWhenDone(decryptedResults);
          },
          progress: 1);
    }

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

  List<FileWrapper> getImagesInCurrentPath() {
    List<FileWrapper> images = [];

    for (var file in _controller.viewState.value.files) {
      if (file.file.type == SavedFileType.IMAGE.index) {
        images.add(file);
      }
    }

    return images;
  }
}
