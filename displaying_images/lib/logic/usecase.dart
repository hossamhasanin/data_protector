import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:base/encrypt/encryption.dart';
import 'package:base/models/user.dart';
import 'package:displaying_images/logic/datasource.dart';
import 'package:displaying_images/logic/decrypt_isolate_vars.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:stream_channel/isolate_channel.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'GetImagesStreamWrapper.dart';
import 'helper_functions.dart';

fetchFilesIsolate(DecryptIsolateVars vars) async {
  SendPort statePort = vars.isolateStatePort;
  String path = vars.currentPath;
  String key = vars.key;
  String platformDir = vars.platformDirPath;
  IsolateChannel state = IsolateChannel.connectSend(statePort);
  SendPort deletingFilesPort = vars.deleteFilesPort;
  Queue<List<F.File>> files = vars.newToLoadFiles;
  Future<FileWrapper> decryptImage(file, key) {
    print("koko decrypt now");
    return vars.useCase.decryptImage(file, key, platformDir);
  }

  var deletingFilesChannel = IsolateChannel.connectSend(deletingFilesPort);

  print("koko > all files in database is " + files.length.toString());

  if (files.isNotEmpty) {
    while (files.isNotEmpty) {
      List<Future<FileWrapper> Function()> batchFiles = [];
      var fileLists = files.removeFirst();
      for (var file in fileLists) {
        if (vars.loadedFiles.contains(file)) {
          continue;
        }

        if (file.type == SavedFileType.IMAGE.index) {
          print("koko I am working here ");
          batchFiles.add(() => decryptImage(file, key));
        } else {
          var isFolderExist =
              await Directory(platformDir + path + file.name).exists();
          if (!isFolderExist) {
            GetImagesStreamWrapper imagesStreamWrapper = GetImagesStreamWrapper(
                images: [],
                done: false,
                error: "'${file.name}' folder does not exist anymore");
            state.sink.add(imagesStreamWrapper);

            deletingFilesChannel.sink.add(file);

            print("koko error loading the images > files error");
          } else {
            batchFiles.add(() => Future.value(FileWrapper(
                file: file, uint8list: null, thumbUint8list: null)));
          }
        }
      }
      try {
        // var s = Stopwatch();
        // s.start();
        var decryptedFiles = await Future.wait(batchFiles.map((e) => e()));
        // print("koko execution time decrypting " +
        //     s.elapsed.inMilliseconds.toString());
        GetImagesStreamWrapper imagesStreamWrapper = GetImagesStreamWrapper(
            images: decryptedFiles, done: false, error: "");
        state.sink.add(imagesStreamWrapper);
        batchFiles.clear();
      } catch (e) {
        print("koko error loading the images > " + e.toString());

        for (var file in fileLists) {
          deletingFilesChannel.sink.add(file);
        }
        var imagesStreamWrapper = GetImagesStreamWrapper(
            images: [],
            done: false,
            error: "Can't decrypt those images , their key is diffrent");
        state.sink.add(imagesStreamWrapper);
      }
      // await Future.delayed(Duration(seconds: 3));
    }

    GetImagesStreamWrapper imagesStreamWrapper =
        GetImagesStreamWrapper(images: [], done: true, error: "");
    state.sink.add(imagesStreamWrapper);
  } else {
    GetImagesStreamWrapper imagesStreamWrapper =
        GetImagesStreamWrapper(images: [], done: true, error: "");
    state.sink.add(imagesStreamWrapper);
  }
}

class DisplayingImagesUseCase {
  final DisplayingImagesDataSource _dataSource;
  final Encrypt _encrypt;

  DisplayingImagesUseCase(this._dataSource, this._encrypt);

  Future<Queue<List<F.File>>> getFiles(String path, int lastFileIndex) async {
    var files = await _dataSource.getFiles(path, lastFileIndex);
    Queue<List<F.File>> filesQueue = Queue();
    for (var file in files) {
      if (filesQueue.isEmpty) {
        filesQueue.add([]);
        var list = filesQueue.last;
        list.add(file);
      } else {
        var list = filesQueue.last;
        if (list.length == FILES_PER_PROCESS) {
          filesQueue.add([]);
          list = filesQueue.last;
          list.add(file);
        } else {
          var list = filesQueue.last;
          list.add(file);
        }
      }
    }
    return filesQueue;
  }

  Future<FileWrapper> decryptImage(
      F.File file, String key, String platformDir) async {
    print("dec im path > " + "$platformDir${file.path}${file.name}");
    var encImageFile =
        File("$platformDir${file.path}${file.name}").readAsBytesSync();

    var decImageFile = _encrypt.decrypt(encImageFile, key);
    Uint8List decThumbFile;

    var thumbName = getThumbName(file.name);
    var encThumbFile = File(platformDir + file.path + thumbName);
    if (encThumbFile.existsSync()) {
      print("koko thumb image exists");

      decThumbFile = _encrypt.decrypt(encThumbFile.readAsBytesSync(), key);
    } else {
      print("koko thumb with name $thumbName not seen");
      Image image = decodeImage(decImageFile)!;

      // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
      Image thumbnail = copyResize(image, width: THUMB_SIZE);

      decThumbFile = Uint8List.fromList(encodePng(thumbnail));
      var encryptThumb = _encrypt.encrypt(decThumbFile, key);

      // Save the thumbnail as a PNG.
      File(platformDir + file.path + thumbName)
          .writeAsBytesSync(encryptThumb.bytes);
      print("koko made your thumb file go and see it ");
    }

    return FileWrapper(
        file: file, uint8list: decImageFile, thumbUint8list: decThumbFile);
  }

  Future encryptImage(FileWrapper image, String key) async {
    var dir = await getExternalStorageDirectory();

    var imagePath = "${dir!.path}${image.file.path}${image.file.name}";
    var thumbFilePath =
        "${dir.path}${image.file.path}${getThumbName(image.file.name)}";
    print("koko image path >" + imagePath);

    var encryptedImage = _encrypt.encrypt(image.uint8list!, key);
    var encryptedThumb = _encrypt.encrypt(image.thumbUint8list!, key);
    await savePhysicalImage(encryptedImage.bytes, imagePath);
    await savePhysicalImage(encryptedThumb.bytes, thumbFilePath);
    await _dataSource.addFile(image.file);
  }

  Future<F.File> createImageFile(String path) async {
    var dateTime = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll("-", "_")
        .replaceAll(":", "_");

    var _imageFileName = "$dateTime.$ENC_EXTENSION";
    // var _thumbFileName = "$dateTime$THUMB_FILE_ENC_EXTENSION.$ENC_EXTENSION";

    return F.File(
        name: _imageFileName,
        id: dateTime,
        path: path,
        type: SavedFileType.IMAGE.index);
  }

  Future<dynamic> deleteFile(F.File file) async {
    try {
      var dir = await getExternalStorageDirectory();
      var fileName = dir!.path + file.path + file.name;
      await _dataSource.deleteFile(file).whenComplete(() {
        print("koko > deleted " + file.id);
      });
      if (file.type == SavedFileType.IMAGE.index) {
        await deletePhysicalFile(fileName);
        if (File(dir.path + file.path + getThumbName(file.name)).existsSync()) {
          await deletePhysicalFile(getThumbName(fileName));
        }
      } else {
        await deletePhysicalDirectory(fileName);
      }
    } catch (e) {
      print("koko > error deleting file " + file.id);
      print("koko delete error " + e.toString());
      return DataException(
          "", DisplayImagesErrorCodes.couldNotDeleteFiles.toString());
    }
  }

  Future<String> getEncryptionKey() async {
    return await _dataSource.getEncryptionKey();
  }

  Future<User> getUserData() async {
    return await _dataSource.getUser();
  }

  Future<dynamic> addNewFolder(F.File file) async {
    try {
      var dir = await getExternalStorageDirectory();
      await createDirectory(dir!.path + file.path + file.name);
      await _dataSource.addFile(file);
      return null;
    } on DataException catch (e) {
      return e;
    }
  }

  Future decryptImagesBackToGallery(FileWrapper image) async {
    try {
      var dir = await getExternalStorageDirectory();
      var decryptedImagesPath =
          await Directory('${dir!.path}/decrypted').create(recursive: true);

      var name = image.file.name.replaceAll(".$ENC_EXTENSION", ".jpg");
      print("koko de name " + image.file.name);
      await savePhysicalImage(
          image.uint8list!, "${decryptedImagesPath.path}/$name");
      await PhotoManager.editor.saveImage(image.uint8list!, title: name);
      await deletePhysicalFile(dir.path + image.file.path + image.file.name);
      await deletePhysicalFile(
          dir.path + image.file.path + getThumbName(image.file.name));
      await _dataSource.deleteFile(image.file);
    } catch (e) {
      print("koko decrypt images to gallery error > " + e.toString());
      return DataException(
          "", DisplayImagesErrorCodes.couldNotDecryptImages.toString());
    }
  }

  // create function to share encrypted images to other apps
  Future<dynamic> shareEncryptedImages(
      List<FileWrapper> images, String path) async {
    try {
      var dir = await getExternalStorageDirectory();
      // map images to File io objects
      List<File> files = [];
      for (var image in images) {
        files.add(File(dir!.path + image.file.path + image.file.name));
        files.add(
            File(dir.path + image.file.path + getThumbName(image.file.name)));
      }
      // create a File io object to store zip file with name of current time stamp
      var zipFile =
          File("${dir!.path}/${DateTime.now().millisecondsSinceEpoch}.zip");
      await ZipFile.createFromFiles(
          sourceDir: Directory(dir.path + path),
          files: files,
          zipFile: zipFile);
      // share the zip file
      await Share.shareFiles([zipFile.path]);
    } catch (e) {
      print("koko share encrypted images error > " + e.toString());
      return DataException(
          "", DisplayImagesErrorCodes.failedToCompressImages.toString());
    }
  }

  Future<dynamic> importEncryptedImages(
      File zipFile, String path, String encKey) async {
    try {
      var dir = await getExternalStorageDirectory();
      // create a Directory object to store encrypted images
      var encryptedImagesPath =
          await Directory(dir!.path + path).create(recursive: true);

      List<Future<FileWrapper> Function()> filesDecryptingTask = [];
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: encryptedImagesPath,
          onExtracting: (zFile, progress) {
            print("koko extracting ${zFile.name} $progress");

            if (!zFile.name.endsWith(".$ENC_EXTENSION")) {
              throw DataException(
                  "", DisplayImagesErrorCodes.failedToImportImages.toString());
            }

            if (!zFile.name.contains(THUMB_FILE_ENC_EXTENSION)) {
              // print("koko thumb file");
              var dateTime = DateTime.now()
                  .toUtc()
                  .toIso8601String()
                  .replaceAll("-", "_")
                  .replaceAll(":", "_");
              var imageFile = F.File(
                  id: dateTime,
                  name: zFile.name,
                  path: path,
                  type: SavedFileType.IMAGE.index);

              filesDecryptingTask
                  .add(() => decryptImage(imageFile, encKey, dir.path));
              _dataSource.addFile(imageFile);
            }

            return ZipFileOperation.includeItem;
          });
      await deletePhysicalFile(zipFile.path);
      // for (var item in f) {
      //   filesDecryptingTask.add(decryptImage(item, encKey, dir.path));
      // }
      return await Future.wait(filesDecryptingTask.map((e) => e()));
    } catch (e) {
      print("koko import encrypted images error > " + e.toString());
      return DataException(
          "", DisplayImagesErrorCodes.failedToImportImages.toString());
    }
  }
}
