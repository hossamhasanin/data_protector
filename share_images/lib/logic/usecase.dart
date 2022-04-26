import 'dart:io';
import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:base/datasource/File.dart' as F;
import 'package:path_provider/path_provider.dart';
import 'package:share_images/logic/datasource.dart';
import 'package:share_images/logic/models/device_peer.dart';
import 'package:share_images/logic/item.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'transfer_states.dart';

class ShareImagesUsecase {
  final ShareImagesDataSource _dataSource;

  ShareImagesUsecase(this._dataSource);

  Stream<List<DevicePeer>> getAvailableDevices() =>
      _dataSource.getAvailableDevices();

  Stream<TransferState> getTransferedData() => _dataSource.getTransferedData();

  Future startSendingProcess(List<Uint8List> files) async {
    try {
      await _dataSource.startSendingProcess(files);
    } on DataException catch (e) {
      return e;
    }
  }

  Future connectToDevice(DevicePeer device) async {
    try {
      await _dataSource.connectToDevice(device);
    } on DataException catch (e) {
      return e;
    }
  }

  Future terminate() async {
    try {
      await _dataSource.terminate();
    } on DataException catch (e) {
      return e;
    }
  }

  Future discoverDevices() async {
    try {
      await _dataSource.discoverDevices();
    } on DataException catch (e) {
      return e;
    }
  }

  Future saveTransferredFile(Item item) async {
    try {
      var dir = await getExternalStorageDirectory();
      var receivedDirectory = await Directory(dir!.path + '/received').create();
      var file = await File(receivedDirectory.path + '/' + item.name)
          .writeAsBytes(item.image!);
      await PhotoManager.editor.saveImageWithPath(file.path, title: item.name);
      // await _dataSource
      //     .saveFile(F.File(name: item.name, id: "", path: "", type: 0));
    } on DataException catch (e) {
      return e;
    }
  }
}
