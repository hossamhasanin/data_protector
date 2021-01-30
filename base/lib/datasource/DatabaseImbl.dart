import 'package:base/datasource/Database.dart';
import 'package:base/datasource/File.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class DatabaseImble implements Database{
  Box<File> filesBox;

  @override
  Future<List<File>> getFiles(String path) {
    var list = filesBox.values.where((file) => file.path == path).toList();
    list.sort((p , n) {
      return p.type.compareTo(n.type);
    });
    return Future.value(list);
  }

  @override
  void initDatabase() async {
    if (!Hive.isAdapterRegistered(0)) {
      await Hive.initFlutter();
      Hive.registerAdapter(FileAdapter());
      filesBox = await Hive.openBox<File>("filesBox");
    }
  }

  @override
  Future<void> addOrUpdateFile(File file) {
    return filesBox.put(file.id , file);
  }

  @override
  Future<void> deleteFile(File file) {
    return filesBox.delete(file.id);
  }

  @override
  Future<void> addFiles(List<File> files) {
    return filesBox.addAll(files);
  }

  @override
  Future<void> deleteAllFiles(List<File> files) {
    return filesBox.deleteAll(files);
  }

}