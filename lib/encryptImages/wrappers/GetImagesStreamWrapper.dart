
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';

class GetImagesStreamWrapper{
  bool done;
  bool empty;
  List<ImageFileWrapper> images;
  GetImagesStreamWrapper({this.images , this.done , this.empty});
}