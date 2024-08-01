import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:displaying_images/logic/crypto_manager.dart';
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
  late final CryptoManager _cryptoManager;
  OpenImageViewState viewState = OpenImageViewState.initial();
  int currentIndex = 0;
  late final StreamSubscription<Uint8List> _readyImageStreamSubscription;

  OpenImageController(this.images, this.encryptionKey, this._useCase){
    _cryptoManager = Get.find();
  }

  loadImage(int index) async {
    currentIndex = index;
    viewState = viewState.copy(
        thumbImageBytes: images[currentIndex].thumbUint8list, error: "", currentImageBytes: Uint8List.fromList([]));
    update([index]);
    var dir = await getExternalStorageDirectory();
    // var recievingPort = ReceivePort();
    // await Isolate.spawn<DecryptToGalleryVars>(
        // decryptImageIsolate,
    //     DecryptToGalleryVars(
    //         isolateStatePort: recievingPort.sendPort,
    //         files: [images[index].file],
    //         useCase: _useCase,
    //         osDir: dir!.path,
    //         key: encryptionKey));
    // var result = await recievingPort.first;
    // recievingPort.close();
    
    final imageNameExt = images[index].file.name.split(".$ENC_EXTENSION");
    var i = 0;
    List<Uint8List> encryptedParts = [];
    while (true){
      final image = File("${dir!.path}${images[index].file.path}${imageNameExt[0]}_$i.$ENC_EXTENSION");
      print("${dir.path}${images[index].file.path}${imageNameExt[0]}_$i.$ENC_EXTENSION");
      if (!(await image.exists())) break;

      encryptedParts.add(await image.readAsBytes());
      i += 1;
    }
    

    print("koko found image parts > "+ encryptedParts.length.toString());
    await _cryptoManager.spawnIsolates();
    await _cryptoManager.decryptImageWithLimitedIsolates(encryptedParts, encryptionKey);
  }

  listenToReadyImageStream() {
    _readyImageStreamSubscription = _cryptoManager.readyImageStream.listen((image) {
      viewState = viewState.copy(
        thumbImageBytes: Uint8List.fromList([]),
        error: "",
        currentImageBytes: image);
      update([currentIndex]);
    }, onError: (e) {
      viewState = viewState.copy(
          thumbImageBytes: Uint8List.fromList([]),
          error: "Data decryption error",
          currentImageBytes: Uint8List.fromList([]));
    });
  }

  @override
  void onClose() {
    _readyImageStreamSubscription.cancel();
    _cryptoManager.clean();
    super.onClose();
  }
}
