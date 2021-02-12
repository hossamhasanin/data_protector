import 'dart:typed_data';

import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:equatable/equatable.dart';

class EncryptEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetStoredFiles extends EncryptEvent {
  String path;
  bool clearTheList;
  GetStoredFiles({this.path, this.clearTheList});
  @override
  List<Object> get props => [path, clearTheList];
}

class EncryptImages extends EncryptEvent {
  List<Uint8List> images;
  List<Uint8List> thumbs;
  EncryptImages({this.images, this.thumbs});
  @override
  List<Object> get props => [images, thumbs];
}

class DecryptImages extends EncryptEvent {}

class DeleteFolders extends EncryptEvent {
  List<FileWrapper> folders;
  DeleteFolders({this.folders});
  @override
  // TODO: implement props
  List<Object> get props => [folders];
}

class CreateNewFolder extends EncryptEvent {
  String name;
  CreateNewFolder({this.name});
  @override
  List<Object> get props => [name];
}

class PickingImagesError extends EncryptEvent {
  String error;
  PickingImagesError({this.error});
  @override
  List<Object> get props => [error];
}

class GotImagesEvent extends EncryptEvent {
  List<FileWrapper> images;

  GotImagesEvent({this.images});

  @override
  // TODO: implement props
  List<Object> get props => [images];
}

class ShareImages extends EncryptEvent {}

class ImportEncFiles extends EncryptEvent {}

class DeleteFiles extends EncryptEvent {}

class LogOut extends EncryptEvent {}
