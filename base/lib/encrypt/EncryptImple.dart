import 'dart:convert';
import 'dart:typed_data';

import 'package:base/encrypt/Encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptImple implements Encrypt {
  // final key = Key.fromUtf8("WKOPoDUeQzTXYo7RA5W6Cg==");
  // The iv is concatinated to secret key during encryption and decryption so it has to be constant not random generated
  final iv = IV.fromUtf8("hgguardian");
  @override
  Uint8List decrypt(Uint8List bytes, String key) {
    final encrypter = Encrypter(AES(Key.fromUtf8(key)));
    final decrypted = encrypter.decryptBytes(Encrypted(bytes), iv: iv);
    return Uint8List.fromList(decrypted);
  }

  @override
  Encrypted encrypt(Uint8List bytes, String key) {
    final encrypter = Encrypter(AES(Key.fromUtf8(key)));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    return encrypted;
  }

  @override
  String hash(String text) {
    var bytes = utf8.encode(text);
    var digest = md5.convert(bytes);
    return digest.toString();
  }
}
