import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/encrypt/encryption.dart';
import 'package:displaying_images/logic/helper_functions.dart';
import 'package:path_provider/path_provider.dart';

void cryptoIsolate(List vars) {
  ReceivePort receivePort = ReceivePort();
  SendPort decryptSendPort = vars[0];
  SendPort encryptSendPort = vars[1];
  SendPort sendMyPort = vars[2];
  Encrypt encrypt = vars[3];
  sendMyPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    // final SendPort replyTo = message[1];
    Uint8List filePart = message[0];
    String key = message[1];
    bool isEncrypt = message[2];
    
    if (isEncrypt){
      Uint8List encryptedPart = encrypt.encrypt(filePart, key).bytes;
      encryptSendPort.send(encryptedPart);
      print("koko crypto encrypted");
    } else {
      Uint8List decryptedPart = encrypt.decrypt(filePart, key);
      decryptSendPort.send(decryptedPart);
    }
  });
}
class CryptoManager {
  final Encrypt _encrypt;

  final List<StreamSubscription> _receivePortsSupscriptions = [];
  final List<SendPort> _sendPorts = [];
  final List<Isolate> _isolates = [];

  final HashMap<String, Uint8List> readyData = HashMap();
  final HashMap<String , Uint8List> _encryptedReadyData = HashMap();
  late final StreamController<Uint8List> readyImage;
  late final StreamController<List<Uint8List>> _readyEncryptedParts;
  late Stopwatch stopwatch;

  CryptoManager({required Encrypt encrypt}) : _encrypt = encrypt, readyImage = StreamController.broadcast(), _readyEncryptedParts = StreamController.broadcast();

  int getNumberOfCores() {
    return 3;
  }

  Future<Uint8List> encrypt(Uint8List file, Uint8List thumbnail, String key) {
    final imageParts = splitFile(file);
    _encryptImage(imageParts, key);
    return Future<Uint8List>.sync(() {
      return _encrypt.encrypt(thumbnail, key).bytes;
    });
  }

  List<Uint8List> splitFile(Uint8List file) {
    List<Uint8List> imageParts = [];
    final numSplits = getNumberOfCores();
    int splitSize = (file.length / numSplits).ceil();
    for (int i = 0; i < numSplits; i++) {
      int start = i * splitSize;
      int end = (i + 1) * splitSize;
      if (end > file.length) end = file.length;

      Uint8List part = file.sublist(start, end);

      // Uint8List encryptedPart = _encrypt.encrypt(part, key).bytes;
      imageParts.add(part);
    }
    return imageParts;
  }

  Future spawnIsolates() async {
    if (_receivePortsSupscriptions.isNotEmpty) return;
    int numCores = getNumberOfCores();

    for (int i = 0; i < numCores; i++) {
      ReceivePort decryptReceivePort = ReceivePort();
      ReceivePort encryptReceivePort = ReceivePort();
      ReceivePort getIsolateSendPort = ReceivePort();
      // receivePorts.add(receivePort);
      Isolate isolate = await Isolate.spawn(cryptoIsolate, [decryptReceivePort.sendPort, encryptReceivePort.sendPort, getIsolateSendPort.sendPort, _encrypt]);
      _isolates.add(isolate);
      print("koko spawned isolate num > $i");
      SendPort sendPort = await getIsolateSendPort.first;
      _sendPorts.add(sendPort);

      print("koko received port for isolate num > $i");
      _receivePortsSupscriptions.add(decryptReceivePort.listen((message) {
        readyData[i.toString()] = message;

        if (readyData.length == numCores){
          List<Uint8List> orderedData = [];
          for (int i = 0; i < readyData.length; i++) {
            orderedData.add(readyData[i.toString()]!); 
          }
          readyImage.add(Uint8List.fromList(orderedData.expand((part) => part).toList()));
          readyData.clear();
        }
      }));

      _receivePortsSupscriptions.add(encryptReceivePort.listen((message) {
        _encryptedReadyData[i.toString()] = message;

        if (_encryptedReadyData.length == numCores){
          List<Uint8List> orderedData = [];
          for (int i = 0; i < _encryptedReadyData.length; i++) {
            orderedData.add(_encryptedReadyData[i.toString()]!); 
          }
          _readyEncryptedParts.add(orderedData);
          _encryptedReadyData.clear();
        }
      }));
    }
  }

  _sendPartsToCryptoIsolate(List<Uint8List> encryptedParts, String key, bool isEncrypt) {
    stopwatch = Stopwatch()..start();
    int numSplits = encryptedParts.length;
    int numCores = getNumberOfCores();
    print("koko current send ports ${_sendPorts.length}");
    for (int i = 0; i < numSplits; i++) {
      _sendPorts[i % numCores].send([
        encryptedParts[i], key, isEncrypt
      ]);
    }
  }

  decryptImage(List<Uint8List> encryptedParts, String key) {
    _sendPartsToCryptoIsolate(encryptedParts, key, false);

    // for (Isolate isolate in isolates) {
    //   isolate.kill(priority: Isolate.immediate);
    // }
  }

  _encryptImage(List<Uint8List> imageParts, String key) {
    _sendPartsToCryptoIsolate(imageParts, key, true);
  }
  
  Stream<Uint8List> get readyImageStream =>  readyImage.stream.map((s) {
    stopwatch.stop();
    print('Decryption completed in ${stopwatch.elapsedMilliseconds} ms');
    return s;
  });

  Stream<List<Uint8List>> get readyEncryptedStream => _readyEncryptedParts.stream.map((s) {
    stopwatch.stop();
    print('Decryption completed in ${stopwatch.elapsedMilliseconds} ms');
    return s;
  });

  clean() {
    for (var sub in _receivePortsSupscriptions) {
      sub.cancel();
    }

    for (var isolate in _isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _receivePortsSupscriptions.clear();
    _sendPorts.clear();
    _isolates.clear();
  }

  static Future<List<Uint8List>> loadEncryptedParts(String fileName, String path) async {
    var dir = await getExternalStorageDirectory();
    final imageNameExt = fileName.split(".$ENC_EXTENSION");
    var i = 0;
    List<Uint8List> encryptedParts = [];
    while (true){
      final image = File("${dir!.path}$path${imageNameExt[0]}_$i.$ENC_EXTENSION");
      print("${dir.path}$path${imageNameExt[0]}_$i.$ENC_EXTENSION");
      if (!(await image.exists())) break;

      encryptedParts.add(await image.readAsBytes());
      i += 1;
    }
    return encryptedParts;
  }

  static Future deleteEncryptedParts(String fileName, String filePath) async {
    var dir = await getExternalStorageDirectory();
    final imageNameExt = fileName.split(".$ENC_EXTENSION");
    var i = 0;
    while (true){
      final path = "${dir!.path}$filePath${imageNameExt[0]}_$i.$ENC_EXTENSION";
      final image = File(path);
      if (!(await image.exists())) break;
      print(path);
      await deletePhysicalFile(path);
      i++;
    }
  }
}



// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:base/encrypt/encryption.dart';

// void decryptPart(List vars) {
//   ReceivePort receivePort = ReceivePort();
//   SendPort sendPort = vars[0];
//   Encrypt encrypt = vars[1];
//   sendPort.send(receivePort.sendPort);

//   receivePort.listen((message) {
//     final List<dynamic> data = message[0];
//     final SendPort replyTo = message[1];

//     Uint8List encryptedPart = data[0];
//     String key = data[1];

//     Uint8List decryptedPart = encrypt.decrypt(encryptedPart, key);

//     replyTo.send(decryptedPart);
//   });
// }
// class CryptoManager {
//   final Encrypt _encrypt;

//   CryptoManager({required Encrypt encrypt}) : _encrypt = encrypt;

//   int getNumberOfCores() {
//     return 1;
//   }

//   List encrypt(Uint8List file, Uint8List thumbnail, String key) {
//     List<Uint8List> encryptedParts = [];
//     final numSplits = getNumberOfCores();
//     int splitSize = (file.length / numSplits).ceil();
//     for (int i = 0; i < numSplits; i++) {
//       int start = i * splitSize;
//       int end = (i + 1) * splitSize;
//       if (end > file.length) end = file.length;

//       Uint8List part = file.sublist(start, end);
//       Uint8List encryptedPart = _encrypt.encrypt(part, key).bytes;
//       encryptedParts.add(encryptedPart);
//     }
//     Uint8List thumbnailEncrypted = _encrypt.encrypt(thumbnail, key).bytes;
//     return [encryptedParts, thumbnailEncrypted];
//   }

//   Future<Uint8List> decryptImageWithLimitedIsolates(List<Uint8List> encryptedParts, String key) async {
//       Stopwatch stopwatch = Stopwatch()..start();
//     int numCores = getNumberOfCores();
//     int numSplits = encryptedParts.length;

//     List<ReceivePort> receivePorts = [];
//     List<SendPort> sendPorts = [];
//     List<Isolate> isolates = [];

//     for (int i = 0; i < numCores; i++) {
//       ReceivePort receivePort = ReceivePort();
//       receivePorts.add(receivePort);
//       Isolate isolate = await Isolate.spawn(decryptPart, [receivePort.sendPort, _encrypt]);
//       isolates.add(isolate);

//       SendPort sendPort = await receivePort.first;
//       sendPorts.add(sendPort);
//     }

//     List<Future<Uint8List>> decryptionFutures = [];
//     for (int i = 0; i < numSplits; i++) {
//       Completer<Uint8List> completer = Completer<Uint8List>();
//       decryptionFutures.add(completer.future);
//       ReceivePort responsePort = ReceivePort();

//       sendPorts[i % numCores].send([
//         [encryptedParts[i], key],
//         responsePort.sendPort,
//       ]);

//       responsePort.listen((message) {
//         print("koko cuurent core > ${i % numCores}");
//         completer.complete(message);
//       });
//     }

//     List<Uint8List> decryptedParts = await Future.wait(decryptionFutures);

//     for (Isolate isolate in isolates) {
//       isolate.kill(priority: Isolate.immediate);
//     }

//     stopwatch.stop();
//   print('Decryption completed in ${stopwatch.elapsedMilliseconds} ms');
//     return Uint8List.fromList(decryptedParts.expand((part) => part).toList());
//   }


// }