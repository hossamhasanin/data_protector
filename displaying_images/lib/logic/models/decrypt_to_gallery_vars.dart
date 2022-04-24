import 'dart:isolate';

import 'package:base/datasource/File.dart';
import 'package:displaying_images/logic/usecase.dart';

class DecryptToGalleryVars {
  final SendPort isolateStatePort;
  final List<File> files;
  final String key;
  final String osDir;
  final DisplayingImagesUseCase useCase;

  DecryptToGalleryVars({
    required this.isolateStatePort,
    required this.files,
    required this.useCase,
    required this.osDir,
    required this.key,
  });
}
