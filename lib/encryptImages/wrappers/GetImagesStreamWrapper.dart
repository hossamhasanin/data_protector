import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';

class GetImagesStreamWrapper {
  bool done;
  bool empty;
  List<FileWrapper>? images;
  String? error;
  GetImagesStreamWrapper(
      {required this.images,
      required this.done,
      required this.empty,
      required this.error});
}
