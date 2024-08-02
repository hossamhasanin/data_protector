import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:base/encrypt/encryption.dart';
import 'package:displaying_images/logic/crypto_manager.dart';
import 'package:displaying_images/logic/datasource.dart';
import 'package:displaying_images/logic/models/decrypt_isolate_vars.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/models/decrypt_to_gallery_vars.dart';
import 'package:displaying_images/logic/models/encrypt_isolate_vars.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
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
    print("koko decrypt now with key > "+ key);
    return vars.useCase.decryptThumb(file, key, platformDir);
  }

  var deletingFilesChannel = IsolateChannel.connectSend(deletingFilesPort);

  print("koko > all files in database is " + files.length.toString());

  if (files.isNotEmpty) {
    while (files.isNotEmpty) {
      List<Future<FileWrapper> Function()> batchFiles = [];
      var fileLists = files.removeFirst();
      for (var file in fileLists) {

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
            batchFiles.add(() =>
                Future.value(FileWrapper(file: file, thumbUint8list: null)));
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

Future encryptFilesIsolate(EncryptIsolateVars vars) async {
  List<Future<List> Function()> encryptTasks = [];

  print("Read image files as bytes");
  for (var image in vars.images) {
    var imageBytes = File(image.imageApsolutePath).readAsBytesSync();
    encryptTasks.add(() => vars.useCase.encryptImage(
        FileWrapper(file: image.file!, thumbUint8list: image.thumbnail),
        imageBytes,
        vars.key,
        vars.osDir));
  }

  try {
    print("koko > all files are encrypting with key > "+ vars.key);
    var result = await Future.wait(encryptTasks.map((e) => e()));
    print("koko > all files encrypted");
    Isolate.exit(vars.isolateStatePort, result);
  } catch (e) {
    print("koko error " + e.toString());
    Isolate.exit(
        vars.isolateStatePort,
        DataException(e.toString(),
            DisplayImagesErrorCodes.couldNotEncryptImages.toString()));
  }
}

Future decryptImageIsolate(DecryptToGalleryVars vars) async {
  List<Future<Uint8List> Function()> decryptTasks = [];

  for (var image in vars.files) {
    decryptTasks
        .add(() => vars.useCase.decryptImage(image, vars.key, vars.osDir));
  }

  try {
    var result = await Future.wait(decryptTasks.map((e) => e()));

    Isolate.exit(vars.isolateStatePort, result);
  } catch (e) {
    Isolate.exit(
        vars.isolateStatePort,
        DataException(e.toString(),
            DisplayImagesErrorCodes.couldNotDecryptImages.toString()));
  }
}

Future decryptThumbIsolate(DecryptToGalleryVars vars) async {
  List<Future<FileWrapper> Function()> decryptTasks = [];

  for (var image in vars.files) {
    decryptTasks
        .add(() => vars.useCase.decryptThumb(image, vars.key, vars.osDir));
  }

  try {
    var result = await Future.wait(decryptTasks.map((e) => e()));

    Isolate.exit(vars.isolateStatePort, result);
  } catch (e) {
    Isolate.exit(
        vars.isolateStatePort,
        DataException(e.toString(),
            DisplayImagesErrorCodes.couldNotDecryptImages.toString()));
  }
}

// Future decryptImagesToMemory(DecryptToGalleryVars vars) async {
//   List<Future<Uint8List> Function()> decryptTasks = [];
//   var dir = await getExternalStorageDirectory();
//   for (var image in vars.files) {
//     decryptTasks
//         .add(() => vars.useCase.decryptImage(image, vars.key, dir!.path));
//   }

//   try {
//     var images = await Future.wait(decryptTasks.map((e) => e()));

//     Isolate.exit(vars.isolateStatePort, images);
//   } catch (e) {
//     Isolate.exit(
//         vars.isolateStatePort,
//         DataException(e.toString(),
//             DisplayImagesErrorCodes.couldNotDecryptImages.toString()));
//   }
// }

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

  Future<FileWrapper> decryptThumb(
      F.File file, String key, String platformDir) async {
    print("dec im path > " + "$platformDir${file.path}${file.name}");

    Uint8List decThumbFile;

    var thumbName = getThumbName(file.name);
    var encThumbFile = File(platformDir + file.path + thumbName);
    if (encThumbFile.existsSync()) {
      print("koko thumb image exists");

      decThumbFile = _encrypt.decrypt(encThumbFile.readAsBytesSync(), key);
    } else {
      print("koko thumb with name $thumbName not seen");
      var encImageFile =
          File("$platformDir${file.path}${file.name}").readAsBytesSync();

      var decImageFile = _encrypt.decrypt(encImageFile, key);
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

    return FileWrapper(file: file, thumbUint8list: decThumbFile);
  }

  Future<Uint8List> decryptImage(
      F.File file, String key, String platformDir) async {
    var encImageFile =
        File("$platformDir${file.path}${file.name}").readAsBytesSync();
    var decryptedImage = _encrypt.decrypt(encImageFile, key);
    return decryptedImage;
  }

  // Future<List<Uint8List>> encryptImage(FileWrapper imageWrapper,
  //     Uint8List image, String key, String osDir) async {
  //   // var imagePath = "$osDir${imageWrapper.file.path}${imageWrapper.file.name}";
  //   // var thumbFilePath =
  //   //     "$osDir${imageWrapper.file.path}${getThumbName(imageWrapper.file.name)}";
  //   // print("koko image path >" + imagePath);
  //   // print("koko thumb image path >" + thumbFilePath);

  //   // var encryptedImage = _encrypt.encrypt(image, key);
  //   // var encryptedThumb = _encrypt.encrypt(imageWrapper.thumbUint8list!, key);
  //   // print("koko image encryption finished");
  //   // return [encryptedImage.bytes, encryptedThumb.bytes];
  // }

  Future<List> encryptImage(FileWrapper imageWrapper,
      Uint8List image, String key, String osDir) async {
    // var imagePath = "$osDir${imageWrapper.file.path}${imageWrapper.file.name}";
    // var thumbFilePath =
    //     "$osDir${imageWrapper.file.path}${getThumbName(imageWrapper.file.name)}";
    // print("koko image path >" + imagePath);
    // print("koko thumb image path >" + thumbFilePath);

    // var encryptedImage = _encrypt.encrypt(image, key);
    // var encryptedThumb = _encrypt.encrypt(imageWrapper.thumbUint8list!, key);
    // print("koko image encryption finished");
    // return [encryptedImage.bytes, encryptedThumb.bytes];

    CryptoManager cryptoManager = CryptoManager(encrypt: _encrypt);
    return cryptoManager.encrypt(image, imageWrapper.thumbUint8list!, key); 
  }

  Future saveEncryptedImage(F.File file, List<Uint8List> encryptedImageParts, String osDir) async {
    var i = 0;
    for (var part in encryptedImageParts) {
      final imageNameExt = file.name.split(".$ENC_EXTENSION");
      var imagePath = "$osDir${file.path}${imageNameExt[0]}_$i.$ENC_EXTENSION";
      print("koko encrpted image file part path > " + imagePath);
      await savePhysicalImage(part, imagePath);
      i++;
    }
    await _dataSource.addFile(file);
    print("koko saved successfully ");
  }

  Future saveEncryptedThumb(Uint8List encryptedThumb, String osDir, F.File file) async {
    var thumbFilePath = "$osDir${file.path}${getThumbName(file.name)}";
    await savePhysicalImage(encryptedThumb, thumbFilePath);
  }

  Future<F.File> createImageFile(String path) async {
    var time = DateTime.now();
    var dateTime = time
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
        timeStamp: time.millisecondsSinceEpoch,
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
        await CryptoManager.deleteEncryptedParts(file.name, file.path);
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
      print("koko error create folder " + e.toString());
      return e;
    }
  }

  Future decryptImagesBackToGallery(F.File file, Uint8List image) async {
    try {
      var dir = await getExternalStorageDirectory();
      var decryptedImagesPath =
          await Directory('${dir!.path}/decrypted').create(recursive: true);

      var name = file.name.replaceAll(".$ENC_EXTENSION", ".jpg");
      print("koko de name " + file.name);
      await savePhysicalImage(image, "${decryptedImagesPath.path}/$name");
      await PhotoManager.editor
          .saveImageWithPath("${decryptedImagesPath.path}/$name", title: name);
      await CryptoManager.deleteEncryptedParts(file.name, file.path);
      await deletePhysicalFile(dir.path + file.path + getThumbName(file.name));
      await _dataSource.deleteFile(file);
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
          "", DisplayImagesErrorCodes.failedToShareImages.toString());
    }
  }

  // Future<dynamic> shareDecryptedImages(
  //     List<FileWrapper> images, String path) async {
  //   try {
  //     var dir = await getExternalStorageDirectory();
  //     var tempDirectory = DateTime.now()
  //         .toUtc()
  //         .toIso8601String()
  //         .replaceAll("-", "_")
  //         .replaceAll(":", "_");
  //     var tempDir = Directory("${dir!.path}/$tempDirectory");
  //     for (var image in images) {
  //       await savePhysicalImage(image.uint8list!,
  //           "${dir.path}/${tempDirectory}}/${image.file.name}");
  //     }
  //   } catch (e) {
  //     print("koko share encrypted images error > " + e.toString());
  //     return DataException(
  //         "", DisplayImagesErrorCodes.failedToShareImages.toString());
  //   }
  // }

  Future<dynamic> importEncryptedImages(
      File zipFile, String path, String encKey) async {
    try {
      var dir = await getExternalStorageDirectory();
      // create a Directory object to store encrypted images
      var encryptedImagesPath =
          await Directory(dir!.path + path).create(recursive: true);

      List<Future<F.File> Function()> filesDecryptingTask = [];
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
              var time = DateTime.now();
              var dateTime = time
                  .toUtc()
                  .toIso8601String()
                  .replaceAll("-", "_")
                  .replaceAll(":", "_");
              var imageFile = F.File(
                  id: dateTime,
                  name: zFile.name,
                  path: path,
                  timeStamp: time.millisecondsSinceEpoch,
                  type: SavedFileType.IMAGE.index);

              filesDecryptingTask.add(() async {
                await _dataSource.addFile(imageFile);
                return imageFile;
                // return decryptThumb(imageFile, encKey, dir.path);
              });
            }

            return ZipFileOperation.includeItem;
          });

      var files = await Future.wait(filesDecryptingTask.map((e) => e()));
      var port = ReceivePort();
      await Isolate.spawn<DecryptToGalleryVars>(
          decryptThumbIsolate,
          DecryptToGalleryVars(
              isolateStatePort: port.sendPort,
              files: files,
              useCase: this,
              osDir: dir.path,
              key: encKey));
      var result = await port.first;
      port.close();
      // await deletePhysicalFile(zipFile.path);
      // for (var item in f) {
      //   filesDecryptingTask.add(decryptImage(item, encKey, dir.path));
      // }
      return result;
    } on DataException catch (e) {
      return e;
    } catch (e) {
      print("koko import encrypted images error > " + e.toString());
      // return DataException(
      //     "", DisplayImagesErrorCodes.failedToImportImages.toString());
    }
  }
}
