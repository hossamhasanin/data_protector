import 'package:base/datasource/File.dart';

abstract class Database {
  Future initDatabase(String userId);
  Future<List<File>> getFiles(String path);
  Future<void> addOrUpdateFile(File file);
  // Future<void> addFiles(List<File> files);
  Future<void> deleteFile(File file);
  Future<void> deleteAllFiles(List<File> files);
  // List k();
}
