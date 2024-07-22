import 'package:equatable/equatable.dart';

import 'image_file_wrapper.dart';

// ignore: must_be_immutable
class GetImagesStreamWrapper extends Equatable {
  bool done;
  List<FileWrapper> images;
  String error;
  GetImagesStreamWrapper(
      {required this.images, required this.done, required this.error});

  @override
  List<Object?> get props => [done, images, error];
}
