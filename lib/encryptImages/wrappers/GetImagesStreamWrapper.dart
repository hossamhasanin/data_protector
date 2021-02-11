import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';

class GetImagesStreamWrapper {
  bool done;
  bool empty;
  List<FileWrapper> images;
  String error;
  GetImagesStreamWrapper({this.images, this.done, this.empty, this.error});
}
