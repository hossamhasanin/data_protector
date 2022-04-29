import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/models/decrypt_to_gallery_vars.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:displaying_images/logic/viewstates/open_image_viewstate.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class OpenImageController extends GetxController {
  late final List<FileWrapper> images;

  late final DisplayingImagesUseCase _useCase;
  late final String encryptionKey;
  OpenImageViewState viewState = OpenImageViewState.initial();
  int currentIndex = 0;

  OpenImageController(this.images, this.encryptionKey, this._useCase);

  loadImage(int index) async {
    currentIndex = index;
    viewState = viewState.copy(
        thumbImageBytes: images[currentIndex].thumbUint8list, error: "", currentImageBytes: Uint8List.fromList([]));
    update([index]);
    var dir = await getExternalStorageDirectory();
    var recievingPort = ReceivePort();
    await Isolate.spawn<DecryptToGalleryVars>(
        decryptImageIsolate,
        DecryptToGalleryVars(
            isolateStatePort: recievingPort.sendPort,
            files: [images[index].file],
            useCase: _useCase,
            osDir: dir!.path,
            key: encryptionKey));
    var result = await recievingPort.first;
    recievingPort.close();

    if (result is DataException) {
      viewState = viewState.copy(
          thumbImageBytes: Uint8List.fromList([]),
          error: result.code,
          currentImageBytes: Uint8List.fromList([]));
      update([index]);
    } else {
      var images = result as List<Uint8List>;
      viewState = viewState.copy(
        thumbImageBytes: Uint8List.fromList([]),
        error: "",
        currentImageBytes: images[0]);
      update([index]);
    }
  }
}
