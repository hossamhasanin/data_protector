import 'dart:io';
import 'dart:math' as math;

import 'package:permission_handler/permission_handler.dart';

const _chars =
    "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890#!@%^&*";
math.Random _rnd = math.Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

extension StringExtension on String {
  String capitalizeFirstLetter() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String exctractCurrentFolderName(String name) {
  return name.split("/files").last;
}

Future<File> deleteFile(String fileName) async {
  var permission = Permission.storage;
  if (await permission.status.isGranted) {
    return new File(fileName)..delete();
  } else {
    await permission.request();
    return deleteFile(fileName);
  }
}
