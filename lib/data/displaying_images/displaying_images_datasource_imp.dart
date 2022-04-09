import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:base/datasource/File.dart';
import 'package:base/models/user.dart';
import 'package:data_protector/data/user/user_supplier.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:displaying_images/logic/datasource.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DisplayingImagesDataSourceImp implements DisplayingImagesDataSource {
  final UserSupplier _userSupplier;

  DisplayingImagesDataSourceImp(this._userSupplier) {
    initDatabase();
  }

  @override
  Future<void> deleteFile(File file) async {
    var filesBox = await Hive.openBox<List>("files");
    if (file.type == SavedFileType.FOLDER.index) {
      await filesBox.delete(file.path + "/" + file.name);
    }
    var list = filesBox.get(file.path);
    var r = list!.remove(file);
    print("koko deleted " + r.toString());
    await filesBox.put(file.path, list);
  }

  @override
  Future<String> getEncryptionKey() async {
    var user = await _userSupplier.getUser();
    if (user == null) {
      throw "User data not present";
    } else {
      return user.encryptionKey;
    }
  }
  //
  // @override
  // Future<List<File>> getFiles(String path, int lastFileIndex , {int pageSize = 20})async {
  //   var filesBox = await Hive.openBox<File>("files");
  //   List<File> list = filesBox.values
  //       .where((file) => file.path == path).toList();
  //   list.sort((p, n) {
  //     return p.type.compareTo(n.type);
  //   });
  //   if (lastFileIndex != -1){
  //     // paginate
  //     list = list.getRange(lastFileIndex+1, filesBox.length).take(pageSize).toList();
  //   } else {
  //     list = list.take(pageSize).toList();
  //   }
  //   return list;
  // }

  @override
  Future<List<File>> getFiles(String path, int lastFileIndex,
      {int pageSize = MAX_PAGE_SIZE}) async {
    var filesBox = await Hive.openBox<List>("files");
    print("koko get files current path " + path);
    var list = filesBox.get(path)!;
    print("koko total amount of files > " + list.length.toString());
    list.sort((p, n) {
      return p.type.compareTo(n.type);
    });
    if (lastFileIndex != -1) {
      // paginate
      list =
          list.getRange(lastFileIndex + 1, list.length).take(pageSize).toList();
    } else {
      list = list.take(pageSize).toList();
    }
    return List<File>.from(list);
  }

  @override
  Future<User> getUser() async {
    var user = await _userSupplier.getUser();
    if (user == null) {
      throw "User data not present";
    } else {
      return user;
    }
  }

  @override
  Future addFile(File file) async {
    var filesBox = await Hive.openBox<List>("files");
    // var parentPath = getParentPath(file.path);
    if (filesBox.containsKey(file.path)) {
      var list = filesBox.get(file.path);
      if (!list!.contains(file)) {
        list.add(file);
        await filesBox.put(file.path, list);
        if (file.type == SavedFileType.FOLDER.index) {
          await filesBox.put(file.path + "/" + file.name, []);
        }
      } else {
        throw DataException(
            "", DisplayImagesErrorCodes.fileNameAlreadyExists.toString());
      }
    }
  }

  @override
  Future initDatabase() async {
    var filesBox = await Hive.openBox<List>("files");
    if (!filesBox.containsKey("/")) {
      print("koko init database and create default directory");
      filesBox.put("/", []);
    }
  }

  // String getParentPath(String path){
  //   var readyPath = "";
  //   if (path == "/"){
  //     readyPath = "/";
  //     return readyPath;
  //   }
  //
  //   var list = path.split("/");
  //   list.removeLast();
  //   readyPath = list.join("/");
  //
  //   return  readyPath;
  // }

}
