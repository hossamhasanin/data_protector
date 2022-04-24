import 'dart:async';
import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:get/get.dart';
import 'package:share_images/logic/datasource.dart';
import 'package:share_images/logic/models/device_peer.dart';
import 'package:share_images/logic/error_codes.dart';
import 'package:share_images/logic/item.dart';
import 'package:share_images/logic/sending/sending_viewstate.dart';
import 'package:share_images/logic/usecase.dart';
import 'package:share_images/share_images.dart';

class SendingImagesConroller extends GetxController {
  late final ShareImagesUsecase _usecase;
  // create Rx<viewstate>
  final Rx<SendingViewState> viewState = SendingViewState.initial().obs;

  late final Function(String) showErrorDialog;

  StreamSubscription<TransferState>? _transferredDataListener;

  int currentTransferringFileIndex = -1;

  List<Uint8List> images = [];

  SendingImagesConroller(ShareImagesDataSource dataSource) {
    _usecase = ShareImagesUsecase(dataSource);
  }

  Future stratDeviceDiscovery() async {
    var result = await _usecase.discoverDevices();

    if (result is DataException) {
      showErrorDialog(result.code);
    }
  }

  Future startSendingProcess(List<Uint8List> files) async {
    images = files;
    var result = await _usecase.startSendingProcess(files);

    if (result is DataException) {
      showErrorDialog(result.code);
    }
  }

  listenToTransferringData() {
    _transferredDataListener = _usecase.getTransferedData().listen((state) {
      if (state is FailedState) {
        if (viewState.value.files.isEmpty) {
          viewState.value = viewState.value.copy(
            isConnectedToReciever: false,
            dataCouldNotBeSent: true,
          );
          showErrorDialog(ShareImagesErrorCodes.couldNotSendFiles.toString());
          _cancelListeners();
        } else {
          if (currentTransferringFileIndex < viewState.value.files.length - 1 ||
              viewState.value.files.last.file.isEmpty) {
            viewState.value = viewState.value.copy(
              isConnectedToReciever: false,
              dataCouldNotBeSent: true,
            );
            showErrorDialog(ShareImagesErrorCodes.couldNotSendFiles.toString());
            _cancelListeners();
          }
        }
        return;
      }

      if (state is ConnectedState) {
        viewState.value = viewState.value.copy(
          currentDevice: DevicePeer(
              name: state.device.name,
              address: state.device.address,
              type: state.device.type,
              status: state.device.status),
        );

        return;
      }

      if (state is MetaDataState) {
        List<Item> files = [];
        var i = 0;
        for (var file in state.files) {
          files.add(Item(
              name: file.name,
              size: file.size,
              image: images[i],
              file: "",
              progress: 0));
          i += 1;
        }
        viewState.value =
            viewState.value.copy(files: files, isConnectedToReciever: true);
      } else if (state is TransferingState) {
        currentTransferringFileIndex = state.currentTransferedItemIndex;
        List<Item> files = List.from(viewState.value.files);
        int transferred = state.transferedBytes;
        bool done = currentTransferringFileIndex == files.length - 1 &&
            transferred == files[currentTransferringFileIndex].size;
        files[currentTransferringFileIndex] =
            files[currentTransferringFileIndex].copy(
                progress:
                    ((transferred / files[currentTransferringFileIndex].size) *
                            100)
                        .round(),
                file: "");
        viewState.value = viewState.value.copy(files: files, doneSending: done);

        if (done) {
          _cancelListeners();
        }
      }
    });
  }

  _cancelListeners() {
    _transferredDataListener?.cancel();
  }
}
