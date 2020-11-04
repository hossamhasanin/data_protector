import 'package:base/datasource/Database.dart';
import 'package:base/datasource/File.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class DatabaseImble implements Database{
  var filesBox = Hive.box<File>("filesBox");

  @override
  Future<List<File>> getFiles() {
    return Future.value(filesBox.values.toList());
  }

  @override
  void initDatabase() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FileAdapter());
    Hive.openBox<File>("filesBox");
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

}