
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:equatable/equatable.dart';

class EncryptState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitEncryptState extends EncryptState {}

class EncryptDone extends EncryptState {}

class Encrypting extends EncryptState {}

// ignore: must_be_immutable
class EncryptFailed extends EncryptState {
  String error;
  EncryptFailed({required this.error});
  @override
  List<Object> get props => [error];
}

class DecryptState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DecryptDone extends DecryptState {}

class Decrypting extends DecryptState {}

// ignore: must_be_immutable
class DecryptFailed extends DecryptState {
  String error;
  DecryptFailed({required this.error});
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

// ignore: must_be_immutable
class DeleteFolderFailed extends DeleteFolderState {
  String error;
  DeleteFolderFailed({required this.error});
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

// ignore: must_be_immutable
class CreateNewFolderFailed extends CreateNewFolderState {
  String error;
  CreateNewFolderFailed({required this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class GetImagesState {}

class GettingImages extends GetImagesState {}

class GotImages extends GetImagesState {
  List<FileWrapper> images;

  GotImages({required this.images});

  @override
  // TODO: implement props
  List<Object> get props => [images];
}

class GettingImagesFailed extends GetImagesState {
  String error;
  GettingImagesFailed({required this.error});
  @override
  List<Object> get props => [error];
}

class SignOutState {}

class SignedOutSuccessFully extends SignOutState {}

class SignedOutFailed extends SignOutState {
  String error;
  SignedOutFailed({required this.error});
}

class ShareImageState {}

class SharingImage extends ShareImageState {}

class SharedImagesSuccessFully extends ShareImageState {}

class ShareImagesFailed extends ShareImageState {
  String error;
  ShareImagesFailed({required this.error});
}

class ImportEncFilesState {}

class ImportingEncFiles extends ImportEncFilesState {}

class ImportedEncFilesSuccessFully extends ImportEncFilesState {}

class ImportEncFilesFailed extends ImportEncFilesState {
  String error;
  ImportEncFilesFailed({required this.error});
}

class DeleteFilesState {}

class DeletingFiles extends DeleteFilesState {}

class DeleteFilesSuccessFully extends DeleteFilesState {}

class DeleteFilesFailed extends DeleteFilesState {
  String error;
  DeleteFilesFailed({required this.error});
}
