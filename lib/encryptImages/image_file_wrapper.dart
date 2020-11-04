import 'dart:typed_data';

import 'package:base/datasource/File.dart';

class ImageFileWrapper{
  File imageFile;
  Uint8List uint8list;
  ImageFileWrapper({this.imageFile , this.uint8list});
}