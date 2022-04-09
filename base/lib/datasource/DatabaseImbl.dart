import 'dart:collection';

import 'package:base/datasource/Database.dart';
import 'package:base/datasource/File.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseImble implements Database {
  Box<File>? filesBox;

  @override
  Future<List<File>> getFiles(String path) {
    List<File> list = filesBox!.values.toList();
    // list = list.getRange(start, end)
    list = list.where((file) => file.path == path).toList();
    list.sort((p, n) {
      return p.type.compareTo(n.type);
    });
    return Future.value(list);
  }

  @override
  Future<void> initDatabase(String userId) async {
    if (!Hive.isAdapterRegistered(0)) {
      await Hive.initFlutter();
      // filesBox = await Hive.openBox<File>("filesBox");
      filesBox = await Hive.openBox<File>(userId);
    }
  }

  @override
  Future<void> addOrUpdateFile(File file) {
    return filesBox!.put(file.id, file);
  }

  @override
  Future<void> deleteFile(File file) {
    return filesBox!.delete(file.id);
  }

  // @override
  // Future<void> addFiles(List<File> files) {
  //   var map = {};
  //   files.forEach((element) {
  //     map[element.id] = element;
  //   });
  //   return filesBox.putAll(map);
  // }

  @override
  Future<void> deleteAllFiles(List<File> files) {
    return filesBox!.deleteAll(files.map((e) => e.id).toList());
  }

  // List k() {
  //   return filesBox.keys.toList();
  // }
}
