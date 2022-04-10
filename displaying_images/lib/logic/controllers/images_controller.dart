import 'dart:io';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:displaying_images/logic/viewstates/viewstate.dart';
import 'package:get/get.dart';

class ImagesController extends GetxController {
  final DisplayingImagesUseCase _useCase;
  final DisplayingImagesController _controller;

  ImagesController(this._controller, this._useCase);

  encryptImages(List<Uint8List> images, List<Uint8List> thumps) async {
    print("koko encrypt > " + images.length.toString());
    var files = List<FileWrapper>.from(_controller.viewState.value.files);
    List<Future> imagesEncryptionTask = [];

    for (var i = 0; i < images.length; i++) {
      var file = await _useCase.createImageFile(_controller.currentPath.value);
      var wrapper = FileWrapper(
          file: file, uint8list: images[i], thumbUint8list: thumps[i]);
      files.add(wrapper);

      imagesEncryptionTask
          .add(_useCase.encryptImage(wrapper, _controller.encryptionKey));
    }
    _controller.viewState.value =
        _controller.viewState.value.copy(files: files);

    var tasksResults = Future.wait(imagesEncryptionTask);
    tasksResults.then((results) {
      for (var result in results) {
        if (result is DataException) {
          // TODO: show encryption error
          print("koko encryption error > " + result.code);
        }
      }
    });
  }

  decryptImagesToGallery() async {
    if (_controller.selectionViewState.value.isSelectingFolders) {
      return;
    }

    _controller.showStateDialog();
    _controller.dialogState.value = _controller.dialogState.value
        .copy(loading: true, error: "", doneMessage: "", isDone: false);
    if (_controller.selectionViewState.value.selectedFiles.length >
        MAX_DECRYPT_IMAGES) {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false,
          error: DisplayImagesErrorCodes.exceededMaxDecryptNum.toString());
      return;
    }

    List<Future> imageDecryptTasks = [];

    Map<int, FileWrapper> files = {
      for (var e = 0; e < _controller.viewState.value.files.length; e++)
        e: _controller.viewState.value.files[e]
    };
    for (var selected
        in _controller.selectionViewState.value.selectedFiles.keys) {
      imageDecryptTasks.add(_useCase.decryptImagesBackToGallery(
          _controller.viewState.value.files[selected]));
      files.remove(selected);
    }

    var result = await Future.wait(imageDecryptTasks);

    if (result.contains(DataException(
        "", DisplayImagesErrorCodes.couldNotDecryptImages.toString()))) {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false,
          isDone: false,
          doneMessage: "",
          error: DisplayImagesErrorCodes.couldNotDecryptImages.toString());
    } else {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false,
          doneMessage: "Decrypting files done successfully",
          isDone: true,
          error: "");
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
    var result = await Future.wait(extractFilesTasks);
    if (result.contains(DataException(
        "", DisplayImagesErrorCodes.failedToImportImages.toString()))) {
      _controller.dialogState.value = _controller.dialogState.value.copy(
          loading: false,
          isDone: false,
          doneMessage: "",
          error: "Importing failed");
    } else {
      List imagesGroups = List.from(result);
      List<FileWrapper> files = List.from(_controller.viewState.value.files);
      for (var imagesGroup in imagesGroups) {
        files.addAll(List<FileWrapper>.from(imagesGroup));
      }
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
