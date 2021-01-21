import 'dart:io';
import 'dart:typed_data';

import 'package:base/datasource/Database.dart';
import 'package:base/datasource/DatabaseImbl.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/encrypt/encryption.dart';
import 'package:data_protector/encryptImages/wrappers/GetImagesStreamWrapper.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:base/Constants.dart';
import 'package:photo_manager/photo_manager.dart';

class EnnryptImagesUseCase {
  Database dataScource;
  AuthDataSource authDataSource;
  Encrypt encrypting;
  EnnryptImagesUseCase(
      {this.dataScource, this.encrypting, this.authDataSource});

  // Future<List<ImageFileWrapper>> getAllImages() async {
  //   await dataScource.initDatabase();
  //   List<ImageFileWrapper> files = (await dataScource.getFiles()).map((val) {
  //      var encImageFile = new File(val.path).readAsBytesSync();
  //      var decImageFile = encrypting.decrypt(encImageFile);
  //      ImageFileWrapper image = ImageFileWrapper(imageFile: val , uint8list: decImageFile);
  //      return image;
  //   }).toList();
  //   return files;
  // }

  Stream<GetImagesStreamWrapper> getAllImages() async* {
    await dataScource.initDatabase();
    String key = await _getEncKey();
    List<ImageFileWrapper> readyToLoad = [];
    var files = await dataScource.getFiles();
    var c = 0;
    if (files.isNotEmpty) {
      for (var i = 0; i <= files.length - 1; i++) {
        var file = files[i];

        try{
          var encImageFile = new File(file.path).readAsBytesSync();
          var decImageFile = encrypting.decrypt(encImageFile, key);
          ImageFileWrapper image =
          ImageFileWrapper(imageFile: file, uint8list: decImageFile);

          readyToLoad.add(image);
          //yield image;
          if (readyToLoad.length == IMAGES_PER_PROCESS || i == files.length - 1) {
            c += 1;
            GetImagesStreamWrapper imagesStreamWrapper = GetImagesStreamWrapper(
                images: readyToLoad, done: false, empty: false);
            yield imagesStreamWrapper;
            readyToLoad.clear();
            print("koko count > " + c.toString());
          }
        } catch(e){
          dataScource.deleteFile(file);
        }

      }
      GetImagesStreamWrapper imagesStreamWrapper =
          GetImagesStreamWrapper(images: null, done: true, empty: false);
      yield imagesStreamWrapper;
    } else {
      GetImagesStreamWrapper imagesStreamWrapper =
          GetImagesStreamWrapper(images: [], done: false, empty: true);
      yield imagesStreamWrapper;
    }
  }

  Future<String> _getEncKey() {
    return authDataSource.getEncryptionKey();
  }

  Future<Exception> encryptImages(List<Uint8List> images) async {
    String key = await _getEncKey();
    List<F.File> files = [];
    for (var image in images) {
      var dir = await getExternalStorageDirectory();
      var testdir =
          await new Directory('${dir.path}/protected').create(recursive: true);
      print(testdir.path);
      var dateTime = DateTime.now().toUtc().toIso8601String();
      var fileName = "$dateTime.hg";
      var filePath = "${testdir.path}/$fileName";
      var file = F.File(name: fileName, id: dateTime, path: filePath);
      files.add(file);

      var encrypted = encrypting.encrypt(image, key);

      await _saveImage(encrypted.bytes, filePath);
    }
    print("koko > save files " + files.length.toString());
    await dataScource.addFiles(files);
  }

  Future<File> _saveImage(Uint8List image, String fileName) async {
    var permission = Permission.storage;
    if (await permission.status.isGranted) {
      return new File(fileName)..writeAsBytesSync(image);
    } else {
      await permission.request();
      return _saveImage(image, fileName);
    }
  }

  Future<File> _deleteFile(String fileName) async {
    var permission = Permission.storage;
    if (await permission.status.isGranted) {
      return new File(fileName)..delete();
    } else {
      await permission.request();
      return _deleteFile(fileName);
    }
  }

  Future decryptImages(List<ImageFileWrapper> images) async {
    var dir = await getExternalStorageDirectory();
    var decryptedImagesPath =
    await new Directory('${dir.path}/decrypted').create(recursive: true);
    try{
      for (ImageFileWrapper image in images){
        await _saveImage(image.uint8list, "$decryptedImagesPath/${image.imageFile.name}");
        await PhotoManager.editor.saveImage(image.uint8list , title: image.imageFile.name);
        await dataScource.deleteFile(image.imageFile);
        await _deleteFile(image.imageFile.path);
      }
    }catch(e){
      return Future.error(e);
    }
  }
}
