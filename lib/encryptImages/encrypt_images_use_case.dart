import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:base/datasource/Database.dart';
import 'package:base/datasource/DatabaseImbl.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/encrypt/encryption.dart';
import 'package:base/models/user.dart';
import 'package:data_protector/encryptImages/wrappers/GetImagesStreamWrapper.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:base/Constants.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share/share.dart';

class EnnryptImagesUseCase {
  Database dataScource;
  AuthDataSource authDataSource;
  Encrypt encrypting;

  EnnryptImagesUseCase(
      {this.dataScource, this.encrypting, this.authDataSource});

  Stream<GetImagesStreamWrapper> getAllImages({String path}) async* {
    await dataScource.initDatabase();
    String key = await _getEncKey();
    List<FileWrapper> readyToLoad = [];
    var files = await dataScource.getFiles(path);
    // var k = await dataScource.k();
    // print("koko > key " + k.toString());

    print("koko > all files in database is " + files.length.toString());
    var c = 0;
    if (files.isNotEmpty) {
      for (var i = 0; i <= files.length - 1; i++) {
        var file = files[i];
        var decImageFile = null;
        try {
          //
          if (file.type == SavedFileType.IMAGE.index) {
            var encImageFile =
                new File(file.path + "/" + file.name).readAsBytesSync();
            decImageFile = encrypting.decrypt(encImageFile, key);
          } else if (file.type == SavedFileType.FOLDER.index) {
            var isFolderExist = await Directory(path).exists();
            if (!isFolderExist)
              throw FileSystemException(
                  "'${file.name}' folder does not exist anymore");
          }

          FileWrapper readyFile =
              FileWrapper(file: file, uint8list: decImageFile);

          readyToLoad.add(readyFile);

          if (readyToLoad.length == FILES_PER_PROCESS ||
              i == files.length - 1) {
            c += 1;
            GetImagesStreamWrapper imagesStreamWrapper = GetImagesStreamWrapper(
                images: readyToLoad, done: false, empty: false, error: null);
            yield imagesStreamWrapper;
            readyToLoad.clear();
            print("koko count > " + c.toString());
          }
        } catch (e) {
          // if it crashed before the number of processed files complete
          // i want it to load what has been ready and empty its load and delete the corupted file
          // form the database then return to continue the rest of the loop

          GetImagesStreamWrapper imagesStreamWrapper = GetImagesStreamWrapper(
              images: readyToLoad,
              done: false,
              empty: false,
              error: e.toString());
          yield imagesStreamWrapper;
          readyToLoad.clear();

          await dataScource.deleteFile(file).whenComplete(() {
            print("koko > deleted " + file.id);
          });

          print("koko error loading the images > " + e.toString());
          continue;
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

  Future<Exception> encryptImages(List<Uint8List> images, String path) async {
    String key = await _getEncKey();
    List<F.File> files = [];
    for (var image in images) {
      var encrypted = encrypting.encrypt(image, key);

      await _saveFileOnTheApp(path, encrypted.bytes);
    }
    print("koko > save files " + files.length.toString());
    //await dataScource.addFiles(files);
  }

  Future createNewFolder(String name, String curretntPath) async {
    var totalPath = "$curretntPath/$name";
    bool isFoldeExist = await Directory(totalPath).exists();
    if (isFoldeExist) throw "This Folder name is here already";
    await new Directory(totalPath).create();
    var dateTime = DateTime.now().toUtc().toIso8601String();
    var file = F.File(
        name: name,
        id: dateTime,
        path: curretntPath,
        type: SavedFileType.FOLDER.index);
    return await dataScource.addOrUpdateFile(file);
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

  Future decryptImages(List<FileWrapper> images) async {
    var dir = await getExternalStorageDirectory();
    var decryptedImagesPath =
        await new Directory('${dir.path}/decrypted').create(recursive: true);
    try {
      for (FileWrapper image in images) {
        var name = image.file.name.replaceAll(".hg", ".jpg");
        await _saveImage(image.uint8list, "${decryptedImagesPath.path}/$name");
        await PhotoManager.editor.saveImage(image.uint8list, title: name);
        await _deleteFile(image.file.path + "/" + image.file.name);
        await dataScource.deleteFile(image.file);
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future deleteFolders(List<FileWrapper> folders) async {
    FileWrapper scopedFolder = null;
    try {
      for (var folder in folders) {
        scopedFolder = folder;
        await dataScource.deleteFile(folder.file);
        print("koko > deleted the folder from database");
        var path = folder.file.path + "/" + folder.file.name;
        await new Directory(path).delete(recursive: true);
        print("koko > deleted the folder");
        List<F.File> files = await dataScource.getFiles(path);
        print("koko > get stored files");
        if (files.isNotEmpty) {
          await dataScource.deleteAllFiles(files);
        }
        print("koko > deleted the folder stored files");
      }
    } on FileSystemException catch (e) {
      await dataScource.deleteFile(scopedFolder.file);
      print("koko > deleted the folder from database");
      return Future.error(
          "Error while deleting ${scopedFolder.file.name} it appears "
          "that it doesn't exit on the phone any more");
    }
  }

  Future shareImages(List<String> images) {
    return Share.shareFiles(images);
  }

  Future importEncryptedFiles(String path) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['hg'],
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path)).toList();
      print("koko picked enc file > " + files[0].path);

      for (var enc in files) {
        var bytes = await enc.readAsBytes();
        await _saveFileOnTheApp(path, bytes);
      }
    } else {
      // User canceled the picker
    }
  }

  Future _saveFileOnTheApp(String path, Uint8List bytes) async {
    var dateTime = DateTime.now().toUtc().toIso8601String();
    var fileName = "$dateTime.hg";
    var filePath = "$path/$fileName";
    var file = F.File(
        name: fileName,
        id: dateTime,
        path: path,
        type: SavedFileType.IMAGE.index);

    await _saveImage(bytes, filePath);
    await dataScource.addOrUpdateFile(file);
  }

  Future deleteFiles(List<FileWrapper> files) async {
    for (var file in files) {
      await _deleteFile(file.file.path + "/" + file.file.name);
      await dataScource.deleteFile(file.file);
    }
  }

  Future logOut() {
    return authDataSource.logOut();
  }

  Stream<User> userData() {
    return authDataSource.userData;
  }
}
