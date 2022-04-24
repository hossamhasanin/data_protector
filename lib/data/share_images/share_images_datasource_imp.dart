import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:base/datasource/File.dart';
import 'package:share_images/logic/datasource.dart';
import 'package:share_images/logic/models/device_peer.dart';
import 'package:wifi_p2p/device.dart';
import 'package:wifi_p2p/wifi_p2p.dart';
import 'package:share_images/share_images.dart';

class ShareImagesDataSourceImp implements ShareImagesDataSource {
  @override
  Future discoverDevices() async {
    try {
      await WifiP2p.discoverPeers;
    } catch (e) {
      throw DataException(e.toString(),
          ShareImagesErrorCodes.couldNotStartSendingProcess.toString());
    }
  }

  @override
  Stream<TransferState> getTransferedData() {
    return WifiP2p.getTransferredData.map((transferData) {
      if (transferData.filesMetaData != null) {
        return MetaDataState(
            files: transferData.filesMetaData!
                .map((metaData) => TransferItemMetaData(
                    name: metaData.name, size: metaData.size))
                .toList(),
            totalSize: transferData.totalBytes!);
      } else if (transferData.transfereFaild != null) {
        return FailedState();
      } else if (transferData.fileBase64 != null) {
        return ReceivedFileState(
            fileBase64: transferData.fileBase64!,
            currentTransferedItemIndex:
                transferData.currentTransferedItemIndex!);
      } else if (transferData.transferedBytes != null) {
        return TransferingState(
            currentTransferedItemIndex:
                transferData.currentTransferedItemIndex!,
            transferedBytes: transferData.transferedBytes!);
      } else {
        throw "Unknown transfer state";
      }
    });
  }

  @override
  Future startSendingProcess(List<Uint8List> files) async {
    try {
      await WifiP2p.startSendingProcess(files);
    } catch (e) {
      throw DataException(e.toString(),
          ShareImagesErrorCodes.couldNotStartSendingProcess.toString());
    }
  }

  @override
  Future terminate() async {
    try {
      await WifiP2p.cancelConnection();
    } catch (e) {
      throw DataException(
          e.toString(), ShareImagesErrorCodes.couldNotTerminate.toString());
    }
  }

  @override
  Future connectToDevice(DevicePeer device) async {
    try {
      await WifiP2p.connectToDevice(Device(
        name: device.name,
        address: device.address,
        type: device.type,
        status: device.status,
      ));
    } catch (e) {
      throw DataException(
          e.toString(), ShareImagesErrorCodes.couldNotConnect.toString());
    }
  }

  @override
  Stream<List<DevicePeer>> getAvailableDevices() {
    return WifiP2p.getPeersList.map((devices) => devices
        .map((device) => DevicePeer(
              name: device.name,
              address: device.address,
              type: device.type,
              status: device.status,
            ))
        .toList());
  }

  @override
  Future saveFile(File item) {
    // TODO: implement saveFile
    throw UnimplementedError();
  }
}
