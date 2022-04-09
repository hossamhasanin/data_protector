import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:base/datasource/File.dart';
import 'package:base/encrypt/Encrypt.dart';
import 'package:displaying_images/displaying_images.dart';
import 'package:displaying_images/logic/GetImagesStreamWrapper.dart';
import 'package:displaying_images/logic/datasource.dart';
import 'package:displaying_images/logic/viewstates/dialog_state.dart';
import 'package:displaying_images/logic/decrypt_isolate_vars.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:displaying_images/logic/viewstates/viewstate.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_channel/isolate_channel.dart';

class DisplayingImagesController extends GetxController {
  final Rx<ViewSate> viewState = ViewSate.init().obs;
  final Rx<SelectionViewState> selectionViewState =
      SelectionViewState.init().obs;
  final Rx<DialogState> dialogState = DialogState.init().obs;
  late final DisplayingImagesUseCase _useCase;
  late Function() showStateDialog;

  RxString currentPath = "/".obs;

  Isolate? decryptingFilesIsolate;
  ReceivePort? isolateStatePort;
  ReceivePort? deleteFilesPort;

  StreamSubscription? _isolateStateListener;

  StreamSubscription? _isolateDeleteFilesListener;

  String encryptionKey = "";

  DisplayingImagesController(
      DisplayingImagesDataSource dataSource, Encrypt encrypt) {
    _useCase = DisplayingImagesUseCase(dataSource, encrypt);
  }

  selectFile(int fileType, int index) {
    if ((fileType == SavedFileType.IMAGE.index &&
            selectionViewState.value.isSelectingFolders) ||
        (fileType == SavedFileType.FOLDER.index &&
            selectionViewState.value.isSelectingImages)) {
      return;
    }

    Map<int, bool> selected = Map.from(selectionViewState.value.selectedFiles);
    if (selected[index] == null) {
      print("select");
      selected[index] = true;
      selectionViewState.value = selectionViewState.value.copy(
          selectedFiles: selected,
          isSelectingFolders: fileType == SavedFileType.FOLDER.index,
          isSelectingImages: fileType == SavedFileType.IMAGE.index);
    } else {
      selected.remove(index);
      selectionViewState.value = selectionViewState.value.copy(
          selectedFiles: selected,
          isSelectingFolders:
              fileType == SavedFileType.FOLDER.index && selected.isNotEmpty,
          isSelectingImages:
              fileType == SavedFileType.IMAGE.index && selected.isNotEmpty);
      print("koko is selecting images , folders " +
          selectionViewState.value.isSelectingFolders.toString() +
          " , " +
          selectionViewState.value.isSelectingImages.toString());
    }
  }

  cancelSelecting() {
    selectionViewState.value = selectionViewState.value.copy(
        selectedFiles: {}, isSelectingImages: false, isSelectingFolders: false);
  }

  decryptImagesToGallery() async {
    if (selectionViewState.value.isSelectingFolders) {
      return;
    }

    showStateDialog();
    dialogState.value = dialogState.value
        .copy(loading: true, error: "", doneMessage: "", isDone: false);
    if (selectionViewState.value.selectedFiles.length > MAX_DECRYPT_IMAGES) {
      dialogState.value = dialogState.value.copy(
          loading: false,
          error: DisplayImagesErrorCodes.exceededMaxDecryptNum.toString());
      return;
    }

    List<Future> imageDecryptTasks = [];

    Map<int, FileWrapper> files = {
      for (var e = 0; e < viewState.value.files.length; e++)
        e: viewState.value.files[e]
    };
    for (var selected in selectionViewState.value.selectedFiles.keys) {
      imageDecryptTasks.add(
          _useCase.decryptImagesBackToGallery(viewState.value.files[selected]));
      files.remove(selected);
    }

    var result = await Future.wait(imageDecryptTasks);

    if (result.contains(DataException(
        "", DisplayImagesErrorCodes.couldNotDecryptImages.toString()))) {
      dialogState.value = dialogState.value.copy(
          loading: false,
          isDone: false,
          doneMessage: "",
          error: DisplayImagesErrorCodes.couldNotDecryptImages.toString());
    } else {
      dialogState.value = dialogState.value.copy(
          loading: false,
          doneMessage: "Decrypting files done successfully",
          isDone: true,
          error: "");
    }

    selectionViewState.value = selectionViewState.value.copy(
        selectedFiles: {}, isSelectingImages: false, isSelectingFolders: false);

    viewState.value = viewState.value.copy(files: files.values.toList());
  }

  deleteFiles() async {
    showStateDialog();
    dialogState.value = dialogState.value
        .copy(loading: true, doneMessage: "", isDone: false, error: "");
    List<Future> imageDeleteTasks = [];

    Map<int, FileWrapper> files = {
      for (var e = 0; e < viewState.value.files.length; e++)
        e: viewState.value.files[e]
    };
    for (var selected in selectionViewState.value.selectedFiles.keys) {
      imageDeleteTasks
          .add(_useCase.deleteFile(viewState.value.files[selected].file));
      files.remove(selected);
    }
    viewState.value = viewState.value.copy(files: files.values.toList());

    var result = await Future.wait(imageDeleteTasks);

    if (result.contains(DataException(
        "", DisplayImagesErrorCodes.couldNotDeleteFiles.toString()))) {
      dialogState.value = dialogState.value.copy(
          loading: false,
          isDone: false,
          doneMessage: "",
          error: DisplayImagesErrorCodes.couldNotDeleteFiles.toString());
    } else {
      dialogState.value = dialogState.value.copy(
          loading: false,
          isDone: true,
          doneMessage: "Delete files done successfully",
          error: "");
    }

    selectionViewState.value = selectionViewState.value.copy(
        selectedFiles: {}, isSelectingImages: false, isSelectingFolders: false);
  }

  addFolder(String fileName) async {
    File file = File(
        name: fileName, id: "0", path: "/", type: SavedFileType.FOLDER.index);
    var wrapper = FileWrapper(file: file);
    var files = List<FileWrapper>.from(viewState.value.files);
    files.insert(0, wrapper);
    viewState.value = viewState.value.copy(files: files);
    var result = await _useCase.addNewFolder(file);
    if (result is DataException) {
      //TODO: Show error message

      print("koko error > " + result.code);
      // Delete the item back from the list
      files.remove(wrapper);
      viewState.value = viewState.value.copy(files: files);
    }
  }

  encryptImages(List<Uint8List> images, List<Uint8List> thumps) async {
    print("koko encrypt > " + images.length.toString());
    var files = List<FileWrapper>.from(viewState.value.files);
    List<Future> imagesEncryptionTask = [];

    for (var i = 0; i < images.length; i++) {
      var file = await _useCase.createImageFile(currentPath.value);
      var wrapper = FileWrapper(
          file: file, uint8list: images[i], thumbUint8list: thumps[i]);
      files.add(wrapper);

      imagesEncryptionTask.add(_useCase.encryptImage(wrapper, encryptionKey));
    }
    viewState.value = viewState.value.copy(files: files);

    var tasksResults = Future.wait(imagesEncryptionTask);
    tasksResults.then((results) {
      for (var result in results) {
        if (result is DataException) {
          // TODO: show encryption error
          print("koko encryption error > " + result.code);
        }
      }
    });
  }

  getUser() async {
    // viewState.value = viewState.value.copy(user: await _useCase.getUserData());
    viewState.value = viewState.value.copy(
        user: User(
            id: "0",
            email: "email",
            encryptionKey: "encryptionKey",
            name: "koko"));
  }

  loadFiles() async {
    viewState.value = viewState.value.copy(loading: true);

    getUser();

    print("koko load the files");
    var files = await _useCase.getFiles(currentPath.value, -1);
    encryptionKey = await _useCase.getEncryptionKey();

    print("koko files " + files.toString());
    print("koko enc key " + encryptionKey);
    _startIsolate(files, []);
  }

  loadMoreFiles() async {
    if (viewState.value.loadingMore ||
        viewState.value.noMoreData ||
        viewState.value.loading) {
      return;
    }

    viewState.value = viewState.value.copy(loadingMore: true);
    // await Future.delayed(Duration(seconds: 3));
    // viewState.value = viewState.value.copy(loadingMore: false);
    var files = await _useCase.getFiles(
        currentPath.value, viewState.value.files.length - 1);
    if (files.isEmpty) {
      viewState.value =
          viewState.value.copy(loadingMore: false, noMoreData: false);
    } else {
      _startIsolate(files, viewState.value.files);
    }
  }

  _startIsolate(
      Queue<List<File>> newToLoadFiles, List<FileWrapper> loadedFiles) async {
    var dir = await getExternalStorageDirectory();
    _closeIsolate();
    isolateStatePort = ReceivePort();
    deleteFilesPort = ReceivePort();
    decryptingFilesIsolate = await Isolate.spawn<DecryptIsolateVars>(
        fetchFilesIsolate,
        DecryptIsolateVars(
            isolateStatePort: isolateStatePort!.sendPort,
            currentPath: currentPath.value,
            key: encryptionKey,
            platformDirPath: dir!.path,
            deleteFilesPort: deleteFilesPort!.sendPort,
            newToLoadFiles: newToLoadFiles,
            loadedFiles: loadedFiles,
            useCase: _useCase));
    _listenToIsolateStateStream();
    _listenToIsolateDeletingFilesStream();
  }

  _listenToIsolateStateStream() {
    var isolateStateChanel = IsolateChannel.connectReceive(isolateStatePort!);
    _isolateStateListener = isolateStateChanel.stream.listen((state) {
      state as GetImagesStreamWrapper;
      print("koko isolate res > " + state.toString());
      if (state.images.isNotEmpty) {
        print("koko >" + state.images.length.toString());
        List<FileWrapper> allFiles = List.from(viewState.value.files);

        allFiles.addAll(state.images);
        viewState.value = viewState.value.copy(files: allFiles, loading: false);
      }

      if (state.done) {
        viewState.value =
            viewState.value.copy(loadingMore: false, loading: false);
        print("koko > done");
        _closeIsolate();
      }

      if (state.error.isNotEmpty) {
        // TODO: Shew error message
      }
    });
  }

  _listenToIsolateDeletingFilesStream() {
    var isolateDeleteFilesChanel =
        IsolateChannel.connectReceive(deleteFilesPort!);
    _isolateDeleteFilesListener =
        isolateDeleteFilesChanel.stream.listen((file) async {
      await _useCase.deleteFile(file);
    });
  }

  _closeIsolate() {
    if (decryptingFilesIsolate != null) {
      print("koko done stop the isolate");
      _isolateStateListener?.cancel();
      _isolateDeleteFilesListener?.cancel();
      decryptingFilesIsolate?.kill();
      isolateStatePort?.close();
      deleteFilesPort?.close();
      isolateStatePort = null;
      deleteFilesPort = null;
      decryptingFilesIsolate = null;
    }
  }
}
