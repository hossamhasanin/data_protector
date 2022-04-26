import 'dart:typed_data';

import 'package:base/datasource/File.dart';
import 'package:share_images/logic/models/device_peer.dart';

import 'transfer_states.dart';

abstract class ShareImagesDataSource {
  Stream<List<DevicePeer>> getAvailableDevices();
  Stream<TransferState> getTransferedData();
  Future discoverDevices();
  Future startSendingProcess(List<Uint8List> files);
  Future connectToDevice(DevicePeer device);
  Future terminate();

  // Future saveFile(File item);
}
