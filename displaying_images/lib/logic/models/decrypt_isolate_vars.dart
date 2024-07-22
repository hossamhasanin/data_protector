import 'dart:collection';
import 'dart:isolate';
import 'package:base/datasource/File.dart' as F;
import 'package:displaying_images/logic/usecase.dart';

class DecryptIsolateVars {
  final SendPort isolateStatePort;
  final String currentPath;
  final String key;
  final String platformDirPath;
  final SendPort deleteFilesPort;
  final Queue<List<F.File>> newToLoadFiles;
  final DisplayingImagesUseCase useCase;

  DecryptIsolateVars(
      {required this.isolateStatePort,
      required this.currentPath,
      required this.key,
      required this.platformDirPath,
      required this.deleteFilesPort,
      required this.newToLoadFiles,
      required this.useCase});
}
