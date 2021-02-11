import 'dart:async';

import 'package:base/datasource/File.dart';
import 'package:base/models/user.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/encrypt_images_use_case.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class EncryptImagesBloc extends Bloc<EncryptEvent, EncryptState> {
  EnnryptImagesUseCase useCase;

  StreamSubscription _imagesListener;

  RxBool isImageSelecting = false.obs;

  RxBool isFolderSelecting = false.obs;

  RxString dir = "/".obs;

  RxList<FileWrapper> selectedImages = List<FileWrapper>().obs;

  RxList<FileWrapper> selectedFolder = List<FileWrapper>().obs;

  // Note : Using diffrent states like that and diffrent streams i think it could have done better
  // if i put them as a property in single class and call it viewState for example
  Rx<DecryptState> decryptState = DecryptState().obs;
  Rx<DeleteFolderState> deletefolderState = DeleteFolderState().obs;
  Rx<CreateNewFolderState> createNewFolderState = CreateNewFolderState().obs;
  Rx<SignOutState> signOutState = SignOutState().obs;
  Rx<ShareImageState> shareImagesState = ShareImageState().obs;
  Rx<ImportEncFilesState> importEncFilesState = ImportEncFilesState().obs;
  Rx<DeleteFilesState> deleteFilesState = DeleteFilesState().obs;
  // Note : this should have its own state classes too but i was a little lazy to write them
  // so just used quick solution :)
  Rx<Exception> encryptState = Exception().obs;
  RxBool errorWhileDisplayingImage = false.obs;

  Rx<User> user = User().obs;

  EncryptImagesBloc({this.useCase}) : super(InitEncryptState()) {
    user.bindStream(useCase.userData());
  }

  @override
  Stream<EncryptState> mapEventToState(EncryptEvent event) async* {
    if (event is EncryptImages) {
      yield* _encryptImages(event);
    } else if (event is GetStoredFiles) {
      yield* _getFiles(event);
    } else if (event is GotImagesEvent) {
      yield GotImages(images: event.images);
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
    print("koko > load images");
    if (_imagesListener != null) {
      _imagesListener.cancel();
    } else {
      yield GettingImages();
    }
    List<FileWrapper> allImages = [];
    if (state is GotImages && !event.clearTheList) {
      allImages.addAll((state as GotImages).images);
    }
    var dir = await getExternalStorageDirectory();
    var path = event.path == "/" ? "${dir.path}" : event.path;
    print("koko path is > $path");
    if (event.path != "/") {
      this.dir.value = event.path;
    }
    _imagesListener = useCase.getAllImages(path: path).listen((filesWrapper) {
      if (filesWrapper.images != null || filesWrapper.empty) {
        print("koko >" + filesWrapper.images.length.toString());
        allImages.addAll(filesWrapper.images);
      } else if (filesWrapper.done) {
        _imagesListener.cancel();
        _imagesListener = null;
        print("koko > done");
      }

      if (filesWrapper.error != null) {
        errorWhileDisplayingImage = true.obs;
      }

      add(GotImagesEvent(images: allImages));
    });
  }

  Stream<EncryptState> _createNewFolder(CreateNewFolder event) async* {
    createNewFolderState.value = CreatingNewFolder();
    try {
      var mainDir = await getExternalStorageDirectory();
      var path = dir.value == "/" ? "${mainDir.path}" : dir.value;

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
      var path = await _providePath();
      print("koko > enc path $path");
      await useCase.encryptImages(event.images, path);
      encryptState.value = null;
      add(GetStoredFiles(path: dir.value, clearTheList: true));
    } catch (e) {
      encryptState.value = e;
      print("koko > enc error : " + e.toString());
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
      await useCase.shareImages(
          selectedImages.map((im) => im.file.path + im.file.name).toList());
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
    var path = dir.value == "/" ? "${mainDir.path}" : dir.value;
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
