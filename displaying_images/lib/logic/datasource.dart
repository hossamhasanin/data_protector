import 'package:base/Constants.dart';
import 'package:base/datasource/File.dart';
import 'package:base/models/user.dart';

abstract class DisplayingImagesDataSource {
  Future initDatabase();
  Future<List<File>> getFiles(String path , int lastFileIndex , {int pageSize = MAX_PAGE_SIZE});
  Future addFile(File file);
  Future<void> deleteFile(File file);
  Future<String> getEncryptionKey();

  Future<User> getUser();
}