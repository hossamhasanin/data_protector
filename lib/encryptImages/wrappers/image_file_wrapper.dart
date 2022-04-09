import 'dart:typed_data';

import 'package:base/datasource/File.dart';

class FileWrapper {
  File file;
  Uint8List? uint8list;
  Uint8List? thumbUint8list;
  FileWrapper({required this.file, this.uint8list, this.thumbUint8list});
}

enum SavedFileType { FOLDER, IMAGE }
