import 'dart:async';
import 'dart:isolate';

import 'package:base/datasource/File.dart';
import 'package:base/models/user.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/encrypt_images_use_case.dart';
import 'package:data_protector/encryptImages/wrappers/GetImagesStreamWrapper.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:data_protector/util/helper_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_channel/isolate_channel.dart';

class EncryptImagesBloc extends Bloc<EncryptEvent, EncryptState> {
  late EnnryptImagesUseCase useCase;

  RxBool isImageSelecting = false.obs;

  RxBool isFolderSelecting = false.obs;

  RxString dir = "/".obs;

  RxList<FileWrapper> selectedImages = List<FileWrapper>.empty().obs;

  RxList<FileWrapper> selectedFolder = List<FileWrapper>.empty().obs;

  // Note : Using diffrent states like that and diffrent streams i think it could have done better
  // if i put them as a property in single class and call it viewState for example
  Rx<DecryptState> decryptState = DecryptState().obs;
  Rx<DeleteFolderState> deletefolderState = DeleteFolderState().obs;
  Rx<CreateNewFolderState> createNewFolderState = CreateNewFolderState().obs;
  Rx<SignOutState> signOutState = SignOutState().obs;
  Rx<ShareImageState> shareImagesState = ShareImageState().obs;
  Rx<ImportEncFilesState> importEncFilesState = ImportEncFilesState().obs;
  Rx<DeleteFilesState> deleteFilesState = DeleteFilesState().obs;
  Rx<GetImagesState> getImagesState = GetImagesState().obs;
  // Note : this should have its own state classes too but i was a little lazy to write them
  // so just used quick solution :)
  Rx<EncryptState> encryptState = EncryptState().obs;
  RxBool errorWhileDisplayingImage = false.obs;

  ReceivePort? _getFilesRecievePort;
  RxBool clearTheList = true.obs;

  Rx<User> user = User.init().obs;

  Isolate? _getFilesIsolate = null;
  EncryptImagesBloc({required this.useCase}) : super(InitEncryptState()) {
    user.bindStream(useCase.userData());
  }

  @override
  Stream<EncryptState> mapEventToState(EncryptEvent event) async* {
    if (event is EncryptImages) {
      yield* _encryptImages(event);
    } else if (event is GetStoredFiles) {
      yield* _getFiles(event);
    } else if (event is GotImagesEvent) {
      //yield GotImages(images: event.images);
      getImagesState.value = GotImages(images: event.images);
    } else if (event is DecryptImages) {
      yield* _decryptImages();
    } else if (event is CreateNewFolder) {
      yield* _createNewFolder(event);
    } else if (event is DeleteFolders) {
      yield* _deleteFolders(event);
    } else if (event is LogOut) {
      yield* _logOut();
    } else if (event is ShareImages) {
      yield* _shareImages();
    } else if (event is ImportEncFiles) {
      yield* _importEncFiles();
    } else if (event is DeleteFiles) {
      yield* _deleteFiles();
    }
  }

  // Stream<EncryptState> getAllImages() async* {
  //   print("koko > load images");
  //   yield GettingImages();
  //   var images = await useCase.getAllImages();
  //   print("koko > "+ images.length.toString());
  //   yield GotImages(images: images);
  // }

  Stream<EncryptState> _getFiles(GetStoredFiles event) async* {
    if (_getFilesIsolate != null && _getFilesRecievePort != null) {
      print("koko stop the isolate");
      _getFilesIsolate?.pause();
      _getFilesRecievePort?.close();
      _getFilesIsolate?.kill();
      _getFilesRecievePort = null;
      _getFilesIsolate = null;
    }
    print("koko > load images");
    getImagesState.value = GettingImages();
    var dir = await getExternalStorageDirectory();
    var path = event.path == "/" ? "${dir!.path}/${user.value.id}" : event.path;
    // var path = await _providePath();
    print("koko path is > $path");
    if (event.path != "/") {
      this.dir.value = event.path;
    }
    clearTheList.value = event.clearTheList;
    _getFilesRecievePort = ReceivePort();
    _getFilesIsolate = await useCase.getAllImages(
        path: path, receivePort: _getFilesRecievePort!, userId: user.value.id);

    _getFilesStreamListener();
  }

  _getFilesStreamListener() {
    var _getFilesChannel = IsolateChannel.connectReceive(_getFilesRecievePort!);
    List<FileWrapper> allImages = [];
    _getFilesChannel.stream.listen((filesWrapper) {
      if (clearTheList.value) {
        allImages.clear();
      }
      print("koko isolate res > " + filesWrapper.toString());
      if (filesWrapper.images != null || filesWrapper.empty) {
        clearTheList.value = false;
        print("koko >" + filesWrapper.images.length.toString());
        allImages.addAll(filesWrapper.images);
      } else if (filesWrapper.done) {
        print("koko > done");
        if (_getFilesIsolate != null && _getFilesRecievePort != null) {
          print("koko done stop the isolate");
          _getFilesRecievePort?.close();
          _getFilesIsolate?.kill();
          _getFilesIsolate = null;
          _getFilesRecievePort = null;
        }
      }

      if (filesWrapper.error != null) {
        errorWhileDisplayingImage = true.obs;
      }
      getImagesState.value = GotImages(images: allImages);
    });
  }

  Stream<EncryptState> _createNewFolder(CreateNewFolder event) async* {
    createNewFolderState.value = CreatingNewFolder();
    try {
      // var mainDir = await getExternalStorageDirectory();
      // var path = dir.value == "/" ? "${mainDir!.path}" : dir.value;

      var path = await _providePath();
      // !! Note : this validation part could be better practise to be in its own class
      // but for simplicity i didn't put into one .
      final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
      if (event.name.length < 3) {
        throw "Folder name cann't be so small";
      } else if (event.name.length > 25) {
        throw "Folder name cann't be so long";
      } else if (!validCharacters.hasMatch(event.name)) {
        throw "Folder name cann't have a specail characters of white spaces";
      }

      await useCase.createNewFolder(event.name, path);
      createNewFolderState.value = CreateNewFolderDone();
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      createNewFolderState.value = CreateNewFolderFailed(error: e.toString());
      print(e.toString());
    }
  }

  Stream<EncryptState> _encryptImages(EncryptImages event) async* {
    try {
      encryptState.value = Encrypting();
      var path = await _providePath();
      print("koko > enc path $path");
      await useCase.encryptImages(event.images, event.thumbs, path);
      encryptState.value = EncryptDone();
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      print("koko > enc error : " + e.toString());

      encryptState.value = EncryptFailed(error: "Error while encrypting");
    }
  }

  Stream<EncryptState> _decryptImages() async* {
    decryptState.value = Decrypting();
    try {
      await useCase.decryptImages(selectedImages);
      decryptState.value = DecryptDone();
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      decryptState.value = DecryptFailed(error: e.toString());
      print(e.toString());
    }
  }

  Stream<EncryptState> _deleteFolders(DeleteFolders event) async* {
    deletefolderState.value = DeletingFolder();
    try {
      print("koko > will delete folder ${event.folders.length}");
      await useCase.deleteFolders(event.folders);
      deletefolderState.value = DeleteFolderDone();
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      deletefolderState.value = DeleteFolderFailed(error: e.toString());
      print(e.toString());
    }
  }

  Stream<EncryptState> _logOut() async* {
    try {
      await useCase.logOut();
      signOutState.value = SignedOutSuccessFully();
    } catch (e) {
      signOutState.value = SignedOutFailed(error: e.toString());
    }
  }

  Stream<EncryptState> _shareImages() async* {
    try {
      shareImagesState.value = SharingImage();
      await useCase.shareImages(selectedImages
          .map((file) => file.file.path + "/" + file.file.name)
          .toList());
      shareImagesState.value = SharedImagesSuccessFully();
    } catch (e) {
      shareImagesState.value =
          ShareImagesFailed(error: "Error happend while sharing");
    }
  }

  Stream<EncryptState> _importEncFiles() async* {
    try {
      importEncFilesState.value = ImportingEncFiles();
      var path = await _providePath();
      await useCase.importEncryptedFiles(path);
      importEncFilesState.value = ImportedEncFilesSuccessFully();
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      print("koko error import enc files > " + e.toString());
      print(e);
      importEncFilesState.value =
          ImportEncFilesFailed(error: "Failed while importing");
    }
  }

  Stream<EncryptState> _deleteFiles() async* {
    try {
      deleteFilesState.value = DeletingFiles();
      await useCase.deleteFiles(selectedImages);
      deleteFilesState.value = DeleteFilesSuccessFully();
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      print("koko error delete files > " + e.toString());
      deleteFilesState.value =
          DeleteFilesFailed(error: "Failed while deleting the files");
    }
  }

  Future<String> _providePath() async {
    var mainDir = await getExternalStorageDirectory();
    var path =
        dir.value == "/" ? "${mainDir!.path}/${user.value.id}" : dir.value;
    return path;
  }

  @override
  Future<void> close() {
    decryptState.close();
    signOutState.close();
    deletefolderState.close();
    createNewFolderState.close();
    errorWhileDisplayingImage.close();
    encryptState.close();
    return super.close();
  }
}
