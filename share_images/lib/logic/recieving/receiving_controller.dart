import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:get/get.dart';
import 'package:share_images/logic/datasource.dart';
import 'package:share_images/logic/models/device_peer.dart';
import 'package:share_images/logic/error_codes.dart';
import 'package:share_images/logic/item.dart';
import 'package:share_images/logic/usecase.dart';
import 'package:share_images/share_images.dart';

import 'receiving_viewstate.dart';

class ReceivingController extends GetxController {
  late final ShareImagesUsecase _usecase;

  // create rx viewstate
  final Rx<ReceivingViewState> viewState = ReceivingViewState.initial().obs;

  late final Function(String) showErrorDialog;
  late final Function() showDoneRecievingDialog;

  StreamSubscription<TransferState>? _transferredDataListener;

  StreamSubscription<List<DevicePeer>>? _discoveredDevicesListener;

  int currentTransferringFileIndex = -1;

  ReceivingController(ShareImagesDataSource dataSource) {
    _usecase = ShareImagesUsecase(dataSource);
  }

  Future stratDeviceDiscovery() async {
    viewState.value = viewState.value.copy(isDiscoveringDevices: true);
    var result = await _usecase.discoverDevices();

    if (result is DataException) {
      showErrorDialog(result.code);
    }
  }

  // function to connect to device
  Future connectToDevice(DevicePeer device) async {
    viewState.value =
        viewState.value.copy(senderTringToConnectWith: device.address);
    var result = await _usecase.connectToDevice(device);

    if (result is DataException) {
      viewState.value = viewState.value.copy(senderTringToConnectWith: "");
      showErrorDialog(result.code);
    }
  }

  listenToDiscoveredDevices() {
    _discoveredDevicesListener =
        _usecase.getAvailableDevices().listen((devices) {
      viewState.value = viewState.value.copy(devices: devices);
    });
  }

  listenToTransferringData() {
    _transferredDataListener = _usecase.getTransferedData().listen((state) {
      if (state is FailedState) {
        if (viewState.value.files.isEmpty) {
          viewState.value = viewState.value.copy(
            isConnectedToSender: false,
            isDiscoveringDevices: false,
            dataCouldNotBeReceived: true,
          );
          showErrorDialog(
              ShareImagesErrorCodes.couldNotReceiveFiles.toString());
          _cancelConnection();
        } else {
          if (currentTransferringFileIndex < viewState.value.files.length - 1 ||
              viewState.value.files.last.file.isEmpty) {
            viewState.value = viewState.value.copy(
              isConnectedToSender: false,
              dataCouldNotBeReceived: true,
            );
            showErrorDialog(
                ShareImagesErrorCodes.couldNotReceiveFiles.toString());
            _cancelConnection();
          }
        }
        return;
      }

      if (state is MetaDataState) {
        List<Item> files = state.files
            .map((file) => Item(
                name: file.name,
                size: file.size,
                file: "",
                image: null,
                progress: 0))
            .toList();
        viewState.value = viewState.value.copy(
            files: files,
            isDiscoveringDevices: false,
            devices: [],
            senderTringToConnectWith: "",
            isConnectedToSender: true);
      } else if (state is TransferingState) {
        List<Item> files = List.from(viewState.value.files);
        int transferred = state.transferedBytes;
        files[state.currentTransferedItemIndex] =
            files[state.currentTransferedItemIndex].copy(
                progress: ((transferred /
                            files[state.currentTransferedItemIndex].size) *
                        100)
                    .round(),
                file: "");
        viewState.value = viewState.value.copy(files: files);
      } else if (state is ReceivedFileState) {
        List<Item> files = List.from(viewState.value.files);
        bool done = state.currentTransferedItemIndex == files.length - 1;
        Uint8List image = base64.decode(state.fileBase64);
        files[state.currentTransferedItemIndex] =
            files[state.currentTransferedItemIndex]
                .copy(file: state.fileBase64, image: image, progress: 100);

        print("koko image bytes " +
            files[state.currentTransferedItemIndex].image!.length.toString());
        viewState.value =
            viewState.value.copy(files: files, doneReceiving: done);

        if (done) {
          showDoneRecievingDialog();
          _cancelConnection();
        }
      }
    });
  }

  _cancelConnection() {
    _usecase.terminate();
    _transferredDataListener?.cancel();
    _discoveredDevicesListener?.cancel();
  }
}
