import 'dart:isolate';

import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/models/encrypt_image_wrapper.dart';
import 'package:displaying_images/logic/usecase.dart';

class EncryptIsolateVars {
  final SendPort isolateStatePort;
  final List<EncryptImageWrapper> images;
  final String key;
  final String path;
  final String osDir;
  final DisplayingImagesUseCase useCase;

  EncryptIsolateVars({
    required this.isolateStatePort,
    required this.images,
    required this.useCase,
    required this.osDir,
    required this.path,
    required this.key,
  });
}
