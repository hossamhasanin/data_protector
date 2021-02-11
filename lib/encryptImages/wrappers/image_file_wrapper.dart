import 'dart:typed_data';

import 'package:base/datasource/File.dart';

class FileWrapper {
  File file;
  Uint8List uint8list;
  FileWrapper({this.file, this.uint8list});
}

enum SavedFileType { FOLDER, IMAGE }
