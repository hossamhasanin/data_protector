import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_images/logic/error_codes.dart';
import 'package:share_images/logic/sending/sending_controller.dart';
import 'package:share_images/ui/sending/components/connect_to_receiver_message.dart';
import 'package:share_images/ui/sending/components/sending_files_list.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final SendingImagesConroller _controller =
      Get.put(SendingImagesConroller(Get.find()));

  @override
  void initState() {
    super.initState();

    List<Uint8List> files = Get.arguments;
    _controller.stratDeviceDiscovery();
    _controller.startSendingProcess(files);
    _controller.listenToTransferringData();

    _controller.showErrorDialog = (error) {
      Get.defaultDialog(
        title: "Error",
        content: Text(_translateErrorCodes(error)),
        actions: [
          ElevatedButton(
            child: const Text("Ok"),
            onPressed: () => Get.back(),
          ),
        ],
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Obx(() {
        var viewState = _controller.viewState.value;
        if (viewState.isConnectedToReciever) {
          if (viewState.files.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SendingFilesList(
              files: viewState.files,
              dataCouldNotBeSent: viewState.dataCouldNotBeSent);
        } else {
          if (viewState.currentDevice.name.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ConnectToReceiverMessage(device: viewState.currentDevice);
        }
      }),
    );
  }

  String _translateErrorCodes(String errorCode) {
    if (errorCode == ShareImagesErrorCodes.couldNotDiscoverPeers.toString()) {
      return "Could not discover peers";
    } else if (errorCode ==
        ShareImagesErrorCodes.couldNotSendFiles.toString()) {
      return "Could not send files";
    } else if (errorCode ==
        ShareImagesErrorCodes.couldNotStartSendingProcess.toString()) {
      return "Could not start sending process";
    } else {
      throw Exception("Unknown error code");
    }
  }
}
