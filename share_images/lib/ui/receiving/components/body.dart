import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:share_images/logic/error_codes.dart';
import 'package:share_images/logic/recieving/receiving_controller.dart';
import 'package:share_images/logic/sending/sending_controller.dart';
import 'package:share_images/ui/receiving/components/devices_list.dart';
import 'package:share_images/ui/receiving/components/receiving_files_list.dart';
import 'package:share_images/ui/receiving/components/waiting_to_find_devices.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final ReceivingController _controller =
      Get.put(ReceivingController(Get.find()));

  @override
  void initState() {
    super.initState();

    _controller.stratDeviceDiscovery();
    _controller.listenToDiscoveredDevices();
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

    _controller.showDoneRecievingDialog = () {
      Get.defaultDialog(
        title: "Done",
        content: const Text("All files have been received"),
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
    return WillPopScope(
      onWillPop: () async {
        Get.back(
            result: _controller.viewState.value.files
                .map((file) => file.image)
                .toList());
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Obx(() {
          var viewState = _controller.viewState.value;
          print("koko devices " + viewState.devices.toString());
          if (viewState.isConnectedToSender) {
            if (viewState.files.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ReceivingFilesList(files: viewState.files);
          } else if (viewState.isDiscoveringDevices) {
            if (viewState.devices.isEmpty) {
              return const WaitingToFindDevices();
            }

            return DevicesList(
                connectToDevice: (device) {
                  _controller.connectToDevice(device);
                },
                devices: viewState.devices,
                senderTringToConnectWith: viewState.senderTringToConnectWith);
          } else {
            return Container(
              child: const Center(
                child: Text("No match"),
              ),
            );
          }
        }),
      ),
    );
  }

  String _translateErrorCodes(String errorCode) {
    if (errorCode == ShareImagesErrorCodes.couldNotDiscoverPeers.toString()) {
      return "Could not discover peers";
    } else if (errorCode ==
        ShareImagesErrorCodes.couldNotReceiveFiles.toString()) {
      return "Could not receive files";
    } else if (errorCode ==
        ShareImagesErrorCodes.couldNotTerminate.toString()) {
      return "Could not terminate";
    } else if (errorCode == ShareImagesErrorCodes.couldNotConnect.toString()) {
      return "Could not connect";
    } else {
      throw Exception("Unknown error code");
    }
  }
}
