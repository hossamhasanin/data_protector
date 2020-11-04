import 'dart:io';
import 'dart:typed_data';

import 'package:base/datasource/DatabaseImbl.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:base/encrypt/encryption.dart';
import 'package:data_protector/encryptImages/image_file_wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UseCase {
  DatabaseImble dataScource;
  EncryptImple encrypting;
  UseCase({this.dataScource , this.encrypting});
  Future<List<ImageFileWrapper>> getAllImages() async {
    List<ImageFileWrapper> files = (await dataScource.getFiles()).map((val) {
       var encImageFile = new File(val.path).readAsBytesSync();
       var decImageFile = encrypting.decrypt(encImageFile);
       ImageFileWrapper image = ImageFileWrapper(imageFile: val , uint8list: decImageFile);
       return image;
    }).toList();
    return files;
  }

  Future<Exception> encryptImages(List<Uint8List> images){
    List<F.File> files = [];
    images.forEach((image) async {
      var dir = await getExternalStorageDirectory();
      var testdir = await new Directory('${dir.path}/protected').create(recursive: true);
      print(testdir.path);
      var dateTime = DateTime.now().toUtc().toIso8601String();
      var fileName = "$dateTime.hg";
      var filePath = "${testdir.path}/$fileName";
      var file = F.File(name: fileName , id: dateTime , path: filePath);
      files.add(file);

      var encrypted = encrypting.encrypt(image);

      await _saveImage(encrypted.bytes , filePath);
    });
    dataScource.addFiles(files);
  }

  Future<File> _saveImage(Uint8List image , String fileName) async {
    var permission = Permission.storage;
    if (await permission.status.isGranted){

      return new File(fileName)..writeAsBytesSync(image);
    } else {
      await permission.request();
      return _saveImage(image , fileName);
    }
  }

}