import 'package:base/datasource/File.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';

class DecryptToGalleryParams {
  final List<File> imageFiles;
  final Map<int, FileWrapper> filesAfterDecrypting;

  DecryptToGalleryParams({required this.imageFiles, required this.filesAfterDecrypting});
}