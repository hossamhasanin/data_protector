import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
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
  return name.split(RegExp(r"/files/[a-zA-Z0-9]*")).last;
}

Future deleteFile(String fileName) async {
  var permission = Permission.storage;
  if (await permission.status.isGranted) {
    var file = new File(fileName);
    return file.existsSync() ? file.delete() : throw "File $fileName not found";
  } else {
    await permission.request();
    return deleteFile(fileName);
  }
}

String getThumbName(String fileName) {
  return "${fileName.split(".hg")[0]}_thumb.hg";
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(BuildContext context, int factor) {
  double screenHeight = MediaQuery.of(context).size.height / factor;
  return screenHeight;
}
