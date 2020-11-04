import 'dart:typed_data';

import 'package:base/encrypt/Encrypt.dart';
import 'package:encrypt/encrypt.dart';

class EncryptImple implements Encrypt{
  final key = Key.fromUtf8("WKOPoDUeQzTXYo7RA5W6Cg==");
  final iv = IV.fromLength(16);
  @override
  Uint8List decrypt(Uint8List bytes) {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decryptBytes(Encrypted(bytes), iv: iv);
    return Uint8List.fromList(decrypted);
  }

  @override
  Encrypted encrypt(Uint8List bytes) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    return encrypted;
  }

}