import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'package:base/base.dart';
import 'package:base/datasource/File.dart';
import 'package:displaying_images/displaying_images.dart';
import 'package:displaying_images/logic/GetImagesStreamWrapper.dart';
import 'package:displaying_images/logic/controllers/folders_controller.dart';
import 'package:displaying_images/logic/controllers/images_controller.dart';
import 'package:displaying_images/logic/viewstates/dialog_state.dart';
import 'package:displaying_images/logic/models/decrypt_isolate_vars.dart';
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
  late Future<bool> Function(String) showConfirmDialog;

  RxString currentPath = "/".obs;

  Isolate? decryptingFilesIsolate;
  ReceivePort? isolateStatePort;
  ReceivePort? deleteFilesPort;

  StreamSubscription? _isolateStateListener;

  StreamSubscription? _isolateDeleteFilesListener;

  String encryptionKey = "";

  DisplayingImagesController(this._useCase) {
    Get.put(FoldersController(this, _useCase));
    Get.put(ImagesController(this, _useCase));
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

  deleteFiles() async {

    if (selectionViewState.value.selectedFiles.isEmpty) {
      return;
    }

    final isConfermed = await showConfirmDialog("Are you sure you want to delete the selected files?");
    if (!isConfermed) {
      return;
    }

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

  Future getUser() async {
    viewState.value = viewState.value.copy(user: await _useCase.getUserData());
    // viewState.value = viewState.value.copy(
    //     user: User(
    //         encryptionKey: "encryptionKey",
    //         name: "koko"));
  }

  loadFiles() async {
    viewState.value = viewState.value.copy(loading: true);

    await getUser();

    print("koko load the files");
    var files = await _useCase.getFiles(currentPath.value, -1);
    encryptionKey = viewState.value.user.encryptionKey;

    print("koko files " + files.toString());
    print("koko enc key " + encryptionKey);
    _startIsolate(files);
  }

  Future loadMoreFiles() async {
    if (viewState.value.loadingMore ||
        viewState.value.noMoreData ||
        viewState.value.loading) {
      return;
    }

    // viewState.value = viewState.value.copy(loadingMore: true);
    // await Future.delayed(Duration(seconds: 3));
    // viewState.value = viewState.value.copy(loadingMore: false);
    var files = await _useCase.getFiles(
        currentPath.value, viewState.value.files.length);
    if (files.isEmpty) {
      viewState.value =
          viewState.value.copy(loadingMore: false, noMoreData: true);
    } else {
      _startIsolate(files);
    }
  }

  _startIsolate(
      Queue<List<File>> newToLoadFiles) async {
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
