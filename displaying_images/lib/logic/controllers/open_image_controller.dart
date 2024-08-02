import 'dart:async';
import 'dart:typed_data';
import 'package:displaying_images/logic/crypto_manager.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/viewstates/open_image_viewstate.dart';
import 'package:get/get.dart';

class OpenImageController extends GetxController {
  late final List<FileWrapper> images;

  late final String encryptionKey;
  late final CryptoManager _cryptoManager;
  OpenImageViewState viewState = OpenImageViewState.initial();
  int currentIndex = 0;
  late final StreamSubscription<Uint8List> _readyImageStreamSubscription;

  OpenImageController(this.images, this.encryptionKey){
    _cryptoManager = Get.find();
  }

  loadImage(int index) async {
    currentIndex = index;
    viewState = viewState.copy(
        thumbImageBytes: images[currentIndex].thumbUint8list, error: "", currentImageBytes: Uint8List.fromList([]));
    update([index]);
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
    
    final encryptedParts = await CryptoManager.loadEncryptedParts(images[index].file.name, images[index].file.path);
    

    print("koko found image parts > "+ encryptedParts.length.toString());
    await _cryptoManager.spawnIsolates();
    _cryptoManager.decryptImage(encryptedParts, encryptionKey);
  }

  listenToReadyImageStream() {
    _readyImageStreamSubscription = _cryptoManager.readyImageStream.listen((image) {
      viewState = viewState.copy(
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
    // _cryptoManager.clean();
    super.onClose();
  }
}
