
import 'image_file_wrapper.dart';

class GetImagesStreamWrapper {
  bool done;
  List<FileWrapper> images;
  String error;
  GetImagesStreamWrapper(
      {required this.images,
      required this.done,
      required this.error});
}
