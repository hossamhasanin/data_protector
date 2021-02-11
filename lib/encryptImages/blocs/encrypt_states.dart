import 'dart:typed_data';

import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:equatable/equatable.dart';

class EncryptState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitEncryptState extends EncryptState {}

class EncryptDone extends EncryptState {}

class EncryptFailed extends EncryptState {
  String error;
  EncryptFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class DecryptState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DecryptDone extends DecryptState {}

class Decrypting extends DecryptState {}

class DecryptFailed extends DecryptState {
  String error;
  DecryptFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class DeleteFolderState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DeleteFolderDone extends DeleteFolderState {}

class DeletingFolder extends DeleteFolderState {}

class DeleteFolderFailed extends DeleteFolderState {
  String error;
  DeleteFolderFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class CreateNewFolderState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CreateNewFolderDone extends CreateNewFolderState {}

class CreatingNewFolder extends CreateNewFolderState {}

class CreateNewFolderFailed extends CreateNewFolderState {
  String error;
  CreateNewFolderFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class GettingImages extends EncryptState {}

class GotImages extends EncryptState {
  List<FileWrapper> images;

  GotImages({this.images});

  @override
  // TODO: implement props
  List<Object> get props => [images];
}

class GettingImagesFailed extends EncryptState {
  String error;
  GettingImagesFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class SignOutState {}

class SignedOutSuccessFully extends SignOutState {}

class SignedOutFailed extends SignOutState {
  String error;
  SignedOutFailed({this.error});
}

class ShareImageState {}

class SharingImage extends ShareImageState {}

class SharedImagesSuccessFully extends ShareImageState {}

class ShareImagesFailed extends ShareImageState {
  String error;
  ShareImagesFailed({this.error});
}

class ImportEncFilesState {}

class ImportingEncFiles extends ImportEncFilesState {}

class ImportedEncFilesSuccessFully extends ImportEncFilesState {}

class ImportEncFilesFailed extends ImportEncFilesState {
  String error;
  ImportEncFilesFailed({this.error});
}

class DeleteFilesState {}

class DeletingFiles extends DeleteFilesState {}

class DeleteFilesSuccessFully extends DeleteFilesState {}

class DeleteFilesFailed extends DeleteFilesState {
  String error;
  DeleteFilesFailed({this.error});
}
