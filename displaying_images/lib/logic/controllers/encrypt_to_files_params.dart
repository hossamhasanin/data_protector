import 'package:base/datasource/File.dart';

class EncryptToFilesParams {
  final List<File> imagesFiles;
  final List<String> fileIds;

  EncryptToFilesParams({required this.imagesFiles, required this.fileIds});
  
}