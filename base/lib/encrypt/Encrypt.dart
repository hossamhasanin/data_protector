import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

abstract class Encrypt {
  Encrypted encrypt(Uint8List bytes, String key);
  Uint8List decrypt(Uint8List bytes, String key);
  String hash(String text);
}
