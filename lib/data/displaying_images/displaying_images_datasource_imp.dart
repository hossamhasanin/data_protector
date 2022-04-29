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

  Future<Box<Map>> getFilesBox() async {
    var filesBox = await Hive.openBox<Map>("files");
    return filesBox;
  }

  @override
  Future<void> deleteFile(File file) async {
    // var filesBox = await getFilesBox();
    // if (file.type == SavedFileType.FOLDER.index) {
    //   await filesBox.delete(file.path + "/" + file.name);
    // }
    // var map = filesBox.get(file.path);
    // var r = map!.remove(file.name);
    // print("koko deleted " + r.toString());
    // await filesBox.put(file.path, map);

    var filesBox = await getFilesBox();
    Map? typesMap = filesBox.get(file.path);
    Map foldersMap = typesMap!["folders"];
    Map filesMap = typesMap["files"];
    if (file.type == SavedFileType.FOLDER.index) {
      await filesBox.delete(file.path + "/" + file.name);
      foldersMap.remove(file.name);
      await filesBox.put(file.path, {
        "folders": foldersMap,
        "files": filesMap,
      });
    } else {
      filesMap.remove(file.name);
      await filesBox.put(file.path, {
        "folders": foldersMap,
        "files": filesMap,
      });
    }
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
    print("koko get files current path " + path);
    // var filesBox = await getFilesBox();
    // var folder = filesBox.get(path);
    // if (folder != null) {
    //   var list = folder.values.toList();
    //   print("koko total amount of files > " + list.length.toString());
    //   list.sort((p, n) {
    //     return p.type.compareTo(n.type);
    //   });
    //   if (lastFileIndex != -1) {
    //     // paginate
    //     list = list
    //         .getRange(lastFileIndex + 1, list.length)
    //         .take(pageSize)
    //         .toList();
    //   } else {
    //     list = list.take(pageSize).toList();
    //   }
    //   return List<File>.from(list);
    // } else {
    //   return [];
    // }

    var filesBox = await getFilesBox();
    var folder = filesBox.get(path);
    
    if (filesBox.containsKey(path)) {
      
      Map foldersMap = folder!["folders"];
      Map filesMap = folder["files"];  
      List<File> folders = List<File>.from(foldersMap.values.toList());
      List<File> files = List<File>.from(filesMap.values.toList());
      files.sort((p, n) {
          return n.timeStamp.compareTo(p.timeStamp);
      });
      if (lastFileIndex != -1) {
        // paginate

        
        files = files
            .getRange(lastFileIndex , files.length)
            .take(pageSize)
            .toList();
        return [...files];
      } else {
        files = files.take(pageSize).toList();
        return [...folders , ...files];
      }
    } else {
      return [];
    }
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
    var filesBox = await getFilesBox();
    // var parentPath = getParentPath(file.path);
    // if (filesBox.containsKey(file.path)) {

    //   Map? map = filesBox.get(file.path);
    //   if (map![file.name] == null) {
    //     map[file.name] = file;
    //     await filesBox.put(file.path, map);
    //     if (file.type == SavedFileType.FOLDER.index) {
    //        print("koko datasource create new folder '${file.name}' in path > " +
    //       file.path);
    //       await filesBox.put(file.path + file.name + "/", {});
    //     }
    //   } else {
    //     throw DataException(
    //         "", DisplayImagesErrorCodes.fileNameAlreadyExists.toString());
    //   }
    // }
    if (filesBox.containsKey(file.path)) {
      Map? typesMap = filesBox.get(file.path);
      Map foldersMap = typesMap!["folders"];
      Map filesMap = typesMap["files"];
      if (file.type == SavedFileType.FOLDER.index) {
        if (foldersMap[file.name] == null) {
          print("koko datasource create new folder '${file.name}' in path > " +
              file.path);
          foldersMap[file.name] = file;
          await filesBox
              .put(file.path, {"folders": foldersMap, "files": filesMap});
          await filesBox
              .put(file.path + file.name + "/", {"folders": {}, "files": {}});
        } else {
          throw DataException(
              "", DisplayImagesErrorCodes.fileNameAlreadyExists.toString());
        }
      } else if (file.type == SavedFileType.IMAGE.index) {
        if (filesMap[file.name] == null) {
          filesMap[file.name] = file;
          await filesBox
              .put(file.path, {"folders": foldersMap, "files": filesMap});
        } else {
          throw DataException(
              "", DisplayImagesErrorCodes.fileNameAlreadyExists.toString());
        }
      } else {
        throw DataException(
            "", DisplayImagesErrorCodes.fileNameAlreadyExists.toString());
      }
    }
  }

  @override
  Future initDatabase() async {
    var filesBox = await getFilesBox();
    if (!filesBox.containsKey("/")) {
      print("koko init database and create default directory");
      filesBox.put("/", {"folders": {}, "files": {}});
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
