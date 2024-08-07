import 'package:base/base.dart';
import 'package:base/datasource/File.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/helper_functions.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:get/get.dart';

class FoldersController extends GetxController {
  final DisplayingImagesUseCase _useCase;
  final DisplayingImagesController _controller;

  FoldersController(this._controller, this._useCase);

  addFolder(String fileName) async {
    print("koko new folder path > " + _controller.currentPath.value);
    File file = File(
        name: fileName,
        id: "0",
        path: _controller.currentPath.value,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        type: SavedFileType.FOLDER.index);
    var wrapper = FileWrapper(file: file);
    var files = List<FileWrapper>.from(_controller.viewState.value.files);
    files.insert(0, wrapper);
    _controller.viewState.value =
        _controller.viewState.value.copy(files: files);
    var result = await _useCase.addNewFolder(file);
    if (result is DataException) {
      //TODO: Show error message

      print("koko error > " + result.code);
      // Delete the item back from the list
      files.remove(wrapper);
      _controller.viewState.value =
          _controller.viewState.value.copy(files: files);
    }
  }

  openFolder(File file) {
    if (_controller.selectionViewState.value.selectedFiles.isNotEmpty) {
      return;
    }
    _controller.currentPath.value += file.name + "/";
    _controller.viewState.value = _controller.viewState.value.copy(files: []);
    _controller.loadFiles();
  }

  goBack() {
    if (_controller.selectionViewState.value.selectedFiles.isNotEmpty) {
      return;
    }

    print("koko here "+exctractCurrentFolderName(_controller.currentPath.value));

    if (exctractCurrentFolderName(_controller.currentPath.value) == "/") {
          return;
        }

    // remove last /
    _controller.currentPath.value = _controller.currentPath.value
        .substring(0, _controller.currentPath.value.length - 1);
    _controller.currentPath.value = _controller.currentPath.value
            .substring(0, _controller.currentPath.value.lastIndexOf("/")) +
        "/";

    _controller.viewState.value = _controller.viewState.value.copy(files: []);
    _controller.loadFiles();
  }
}
