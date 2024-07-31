import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/encrypt/encryption.dart';

void decryptPart(List vars) {
  ReceivePort receivePort = ReceivePort();
  SendPort sendPort = vars[0];
  Encrypt encrypt = vars[1];
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    final List<dynamic> data = message[0];
    final SendPort replyTo = message[1];

    Uint8List encryptedPart = data[0];
    String key = data[1];

    Uint8List decryptedPart = encrypt.decrypt(encryptedPart, key);

    replyTo.send(decryptedPart);
  });
}
class CryptoManager {
  final Encrypt _encrypt;

  CryptoManager({required Encrypt encrypt}) : _encrypt = encrypt;

  int getNumberOfCores() {
    return 1;
  }

  List encrypt(Uint8List file, Uint8List thumbnail, String key) {
    List<Uint8List> encryptedParts = [];
    final numSplits = getNumberOfCores();
    int splitSize = (file.length / numSplits).ceil();
    for (int i = 0; i < numSplits; i++) {
      int start = i * splitSize;
      int end = (i + 1) * splitSize;
      if (end > file.length) end = file.length;

      Uint8List part = file.sublist(start, end);
      Uint8List encryptedPart = _encrypt.encrypt(part, key).bytes;
      encryptedParts.add(encryptedPart);
    }
    Uint8List thumbnailEncrypted = _encrypt.encrypt(thumbnail, key).bytes;
    return [encryptedParts, thumbnailEncrypted];
  }

  Future<Uint8List> decryptImageWithLimitedIsolates(List<Uint8List> encryptedParts, String key) async {
      Stopwatch stopwatch = Stopwatch()..start();
    int numCores = getNumberOfCores();
    int numSplits = encryptedParts.length;

    List<ReceivePort> receivePorts = [];
    List<SendPort> sendPorts = [];
    List<Isolate> isolates = [];

    for (int i = 0; i < numCores; i++) {
      ReceivePort receivePort = ReceivePort();
      receivePorts.add(receivePort);
      Isolate isolate = await Isolate.spawn(decryptPart, [receivePort.sendPort, _encrypt]);
      isolates.add(isolate);

      SendPort sendPort = await receivePort.first;
      sendPorts.add(sendPort);
    }

    List<Future<Uint8List>> decryptionFutures = [];
    for (int i = 0; i < numSplits; i++) {
      Completer<Uint8List> completer = Completer<Uint8List>();
      decryptionFutures.add(completer.future);
      ReceivePort responsePort = ReceivePort();

      sendPorts[i % numCores].send([
        [encryptedParts[i], key],
        responsePort.sendPort,
      ]);

      responsePort.listen((message) {
        print("koko cuurent core > ${i % numCores}");
        completer.complete(message);
      });
    }

    List<Uint8List> decryptedParts = await Future.wait(decryptionFutures);

    for (Isolate isolate in isolates) {
      isolate.kill(priority: Isolate.immediate);
    }

    stopwatch.stop();
  print('Decryption completed in ${stopwatch.elapsedMilliseconds} ms');
    return Uint8List.fromList(decryptedParts.expand((part) => part).toList());
  }


}