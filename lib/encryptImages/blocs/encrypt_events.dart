import 'dart:typed_data';

import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:equatable/equatable.dart';

class EncryptEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class GetStoredFiles extends EncryptEvent {
  String path;
  bool clearTheList;
  GetStoredFiles({required this.path, required this.clearTheList});
  @override
  List<Object> get props => [path, clearTheList];
}

// ignore: must_be_immutable
class EncryptImages extends EncryptEvent {
  List<Uint8List> images;
  List<Uint8List> thumbs;
  EncryptImages({required this.images, required this.thumbs});
  @override
  List<Object> get props => [images, thumbs];
}

class DecryptImages extends EncryptEvent {}

// ignore: must_be_immutable
class DeleteFolders extends EncryptEvent {
  List<FileWrapper> folders;
  DeleteFolders({required this.folders});
  @override
  // TODO: implement props
  List<Object> get props => [folders];
}

// ignore: must_be_immutable
class CreateNewFolder extends EncryptEvent {
  String name;
  CreateNewFolder({required this.name});
  @override
  List<Object> get props => [name];
}

// ignore: must_be_immutable
class PickingImagesError extends EncryptEvent {
  String error;
  PickingImagesError({required this.error});
  @override
  List<Object> get props => [error];
}

// ignore: must_be_immutable
class GotImagesEvent extends EncryptEvent {
  List<FileWrapper> images;

  GotImagesEvent({required this.images});

  @override
  List<Object> get props => [images];
}

class ShareImages extends EncryptEvent {}

class ImportEncFiles extends EncryptEvent {}

class DeleteFiles extends EncryptEvent {}

class LogOut extends EncryptEvent {}
