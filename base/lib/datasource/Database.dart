import 'package:base/datasource/File.dart';

abstract class Database {
  void initDatabase();
  Future<List<File>> getFiles();
  Future<void> addOrUpdateFile(File file);
  Future<void> addFiles(List<File> files);
  Future<void> deleteFile(File file);
}