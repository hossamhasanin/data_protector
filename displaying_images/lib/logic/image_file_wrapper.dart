import 'dart:typed_data';

import 'package:base/datasource/File.dart';
import 'package:equatable/equatable.dart';

class FileWrapper extends Equatable {
  File file;
  // Uint8List? uint8list;
  Uint8List? thumbUint8list;
  FileWrapper({required this.file, this.thumbUint8list});

  @override
  List<Object?> get props => [file];
}

enum SavedFileType { FOLDER, IMAGE }
