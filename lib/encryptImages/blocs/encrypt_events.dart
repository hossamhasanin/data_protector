
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class EncryptEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetAllImages extends EncryptEvent{}
class EncryptImages extends EncryptEvent{
  List<Uint8List> images;
  EncryptImages({this.images});
  @override
  List<Object> get props => [images];
}

class PickingImagesError extends EncryptEvent{
  String error;
  PickingImagesError({this.error});
  @override
  List<Object> get props => [error];
}