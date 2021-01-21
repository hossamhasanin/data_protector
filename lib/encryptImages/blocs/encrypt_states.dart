import 'dart:typed_data';

import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:equatable/equatable.dart';

class EncryptState extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitEncryptState extends EncryptState{}

class EncryptDone extends EncryptState{}
class EncryptFailed extends EncryptState{
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

class DecryptDone extends DecryptState{}
class Decrypting extends DecryptState{}
class DecryptFailed extends DecryptState{
  String error;
  DecryptFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class GettingImages extends EncryptState{}

class GotImages extends EncryptState{
  List<ImageFileWrapper> images;

  GotImages({this.images});

  @override
  // TODO: implement props
  List<Object> get props => [images];
}

class GettingImagesFailed extends EncryptState{
  String error;
  GettingImagesFailed({this.error});
  @override
  // TODO: implement props
  List<Object> get props => [error];
}