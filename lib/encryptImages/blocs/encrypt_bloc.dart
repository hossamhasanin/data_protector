import 'dart:async';

import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/encrypt_images_use_case.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EncryptImagesBloc extends Bloc<EncryptEvent , EncryptState>{

  EnnryptImagesUseCase useCase;

  StreamSubscription _imagesListener;

  EncryptImagesBloc({this.useCase}) : super(InitEncryptState());

  @override
  Stream<EncryptState> mapEventToState(EncryptEvent event) async* {
    if (event is EncryptImages){
      yield* encryptImages(event);
    } else if (event is GetAllImages){
      yield* getAllImages();
    } else if (event is GotImagesEvent){
      yield GotImages(images: event.images);
    }
  }

  // Stream<EncryptState> getAllImages() async* {
  //   print("koko > load images");
  //   yield GettingImages();
  //   var images = await useCase.getAllImages();
  //   print("koko > "+ images.length.toString());
  //   yield GotImages(images: images);
  // }

  Stream<EncryptState> getAllImages() async* {
    print("koko > load images");
    if (_imagesListener != null){
      _imagesListener.cancel();
    } else {
      yield GettingImages();
    }
    List<ImageFileWrapper> allImages = [];
    if (state is GotImages){
      allImages.addAll((state as GotImages).images);
    }
    _imagesListener = useCase.getAllImages().listen((imagesWrapper) {
      if (imagesWrapper.images != null || imagesWrapper.empty){
        print("koko >" + imagesWrapper.images.length.toString());
        allImages.addAll(imagesWrapper.images);
        add(GotImagesEvent(images: allImages));
      } else if (imagesWrapper.done){
        _imagesListener.cancel();
        _imagesListener = null;
        print("koko > done");
      }
    });
  }

  Stream<EncryptState> encryptImages(EncryptImages event) async* {
    try{
      await useCase.encryptImages(event.images);
      add(GetAllImages());
    } catch (e){
      yield EncryptFailed(error: e.toString());
    }
  }



}