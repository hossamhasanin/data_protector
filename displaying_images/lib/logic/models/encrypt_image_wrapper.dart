import 'dart:typed_data';

import 'package:base/datasource/File.dart';

class EncryptImageWrapper {
  final String imageApsolutePath;
  final String id;
  final Uint8List thumbnail;
  final File? file;

  EncryptImageWrapper({
    required this.imageApsolutePath,
    required this.id,
    required this.thumbnail,
    this.file,
  });

  // copy method
  EncryptImageWrapper copyWith({
    String? imageApsolutePath,
    String? id,
    Uint8List? thumbnail,
    File? file,
  }) {
    return EncryptImageWrapper(
      imageApsolutePath: imageApsolutePath ?? this.imageApsolutePath,
      id: id ?? this.id,
      thumbnail: thumbnail ?? this.thumbnail,
      file: file ?? this.file,
    );
  }
}
