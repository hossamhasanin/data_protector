import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/encrypt_images_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EncryptImagesBloc extends Bloc<EncryptEvent , EncryptState>{

  UseCase useCase;

  EncryptImagesBloc({this.useCase}) : super(InitEncryptState());

  @override
  Stream<EncryptState> mapEventToState(EncryptEvent event) async* {
    if (event is EncryptImages){
      yield* encryptImages(event);
    } else if (event is GetAllImages){
      yield* getAllImages();
    }
  }

  Stream<EncryptState> getAllImages() async* {
    var images = await useCase.getAllImages();
    yield GotImages(images: images);
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