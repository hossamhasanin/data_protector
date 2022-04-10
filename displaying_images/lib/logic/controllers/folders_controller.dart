import 'package:base/base.dart';
import 'package:base/datasource/File.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:displaying_images/logic/viewstates/viewstate.dart';
import 'package:get/get.dart';

class FoldersController extends GetxController {
  final DisplayingImagesUseCase _useCase;
  final DisplayingImagesController _controller;

  FoldersController(this._controller, this._useCase);

  addFolder(String fileName) async {
    File file = File(
        name: fileName, id: "0", path: "/", type: SavedFileType.FOLDER.index);
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
}
