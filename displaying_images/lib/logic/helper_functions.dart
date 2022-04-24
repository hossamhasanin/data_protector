import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

const _chars =
    "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890#!@%^&*";
math.Random _rnd = math.Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

extension StringExtension on String {
  String capitalizeFirstLetter() {
    return isEmpty ? "" : "${this[0].toUpperCase()}${substring(1)}";
  }
}

String exctractCurrentFolderName(String name) {
  return name.split(RegExp(r"/files/[a-zA-Z0-9]*")).last;
}

Future deletePhysicalFile(String fileName) async {
  var storagePermission = Permission.storage;
  var manageStoragePermission = Permission.manageExternalStorage;
  if (await storagePermission.status.isGranted &&
      await manageStoragePermission.status.isGranted) {
    var file = File(fileName);
    return file.existsSync() ? file.delete() : throw "File $fileName not found";
  } else {
    await storagePermission.request();
    await manageStoragePermission.request();
    return deletePhysicalFile(fileName);
  }
}

Future deletePhysicalDirectory(String dirName) async {
  var permission = Permission.storage;
  if (await permission.status.isGranted) {
    var dir = Directory(dirName);
    return dir.existsSync()
        ? dir.delete(recursive: true)
        : throw "File $dirName not found";
  } else {
    await permission.request();
    return deletePhysicalDirectory(dirName);
  }
}

Future<File> savePhysicalImage(Uint8List image, String fileName) async {
  var permission = Permission.storage;
  if (await permission.status.isGranted) {
    return File(fileName).writeAsBytes(image);
  } else {
    await permission.request();
    return savePhysicalImage(image, fileName);
  }
}

Future createDirectory(String path) async {
  var permission = Permission.storage;
  if (await permission.status.isGranted) {
    await Directory(path).create();
  } else {
    await permission.request();
    return createDirectory(path);
  }
}

String getThumbName(String fileName) {
  return "${fileName.split(".hg")[0]}$THUMB_FILE_ENC_EXTENSION.hg";
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(BuildContext context, int factor) {
  double screenHeight = MediaQuery.of(context).size.height / factor;
  return screenHeight;
}
