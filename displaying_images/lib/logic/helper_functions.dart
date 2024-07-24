import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  var deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt! < 29) {
    var storagePermission = Permission.storage;
    if (!(await storagePermission.status.isGranted)){
      await storagePermission.request();
    } else {
      throw "Error dont have permissions";
    }
  }
  var file = File(fileName);
  return file.existsSync() ? file.deleteSync() : throw "File $fileName not found";
}

Future<bool> requestRequiredPermissions() async {
  if (Platform.isAndroid) {
    var deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt! > 29) {
      return true;
    } else {
      var storagePermission = Permission.storage;
      if (await storagePermission.status.isGranted) {
        return true;
      } else {
        await storagePermission.request();
        return requestRequiredPermissions();
      }
    }
  } else {
    return await _requestMainPermisions();
  }
}

Future<bool> _requestMainPermisions() async {
  var photosPermission = Permission.photos;
  var videosPermission = Permission.videos;
  if (await photosPermission.status.isGranted &&
      await videosPermission.status.isGranted) {
    return true;
  } else {
    var requestedStorage = await photosPermission.request();
    var requestedManageStorage = await videosPermission.request();
    if (requestedManageStorage.isGranted && requestedStorage.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}

Future deletePhysicalDirectory(String dirName) async {
  var deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt! < 29) {
    var permission = Permission.storage;
    if (!(await permission.status.isGranted)) {
      await permission.request();
    } else {
      throw "Error dont have permissions";
    }
  }
  var dir = Directory(dirName);
  return dir.existsSync()
      ? dir.delete(recursive: true)
      : throw "File $dirName not found";
}

Future<File> savePhysicalImage(Uint8List image, String fileName) async {
  var deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt! < 29) {
    var permission = Permission.storage;
    if (!(await permission.status.isGranted)) {
      await permission.request();
    } else {
      throw "Error dont have permissions";
    }
  }
  return await File(fileName).writeAsBytes(image);
}

Future createDirectory(String path) async {
  var deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt! < 29) {
    var permission = Permission.storage;
    if (!(await permission.status.isGranted)) {
      await permission.request();
    } else {
      throw "Error dont have permissions";
    }
  }
  return await Directory(path).create();
}

String getThumbName(String fileName) {
  return "${fileName.split(".hg")[0]}$THUMB_FILE_ENC_EXTENSION.hg";
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(BuildContext context, int factor) {
  double screenHeight = MediaQuery.of(context).size.height / factor;
  return screenHeight;
}
