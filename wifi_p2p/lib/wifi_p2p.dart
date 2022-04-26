import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_p2p/device.dart';
import 'package:wifi_p2p/transfer_data.dart';

import 'item_meta_data.dart';

class WifiP2p {
  static const MethodChannel _channel = MethodChannel('wifi_p2p');
  static const EventChannel _peersStream = EventChannel('peersStream');
  static const EventChannel _transferredDataStream =
      EventChannel('transferredDataStream');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> get discoverPeers async {
    var locationPermission = await Permission.location.request();
    if (locationPermission.isGranted) {
      final String? result = await _channel.invokeMethod('discoverPeers');
      return result;
    }
    return "Location permission error";
  }

  static Stream<List<Device>> get getPeersList async* {
    yield* _peersStream.receiveBroadcastStream().map((list) =>
        (list as List<Object?>)
            .map((peer) => Device(
                name: (peer as Map)["deviceName"],
                address: peer["deviceAddress"],
                type: peer["deviceType"],
                status: peer["status"]))
            .toList());
  }

  static Stream<TransfereData> get getTransferredData async* {
    yield* _transferredDataStream.receiveBroadcastStream().cast().map((map) {
    print("koko wifi_p2p data $map");
      if (map["metaData"] != null) {
        return TransfereData(
          filesMetaData: (map["metaData"]["files"] as List)
              .map((metaData) => ItemMetaData(
                    name: metaData["name"],
                    size: metaData["size"],
                  ))
              .toList(),
          totalBytes: map["metaData"]["totalSize"],
        );
      } else if (map["currentDevice"] != null) {
        return TransfereData(
            thisDevice: Device(
                name: map["currentDevice"]["deviceName"],
                address: map["currentDevice"]["deviceAddress"],
                type: map["currentDevice"]["deviceType"],
                status: map["currentDevice"]["status"]));
      } else if (map["disconnected"] != null) {
        return const TransfereData(transfereFaild: true);
      } else if (map["transferred"] != null) {
        return TransfereData(
            transferedBytes: map["transferred"],
            currentTransferedItemIndex: map["itemIndex"]);
      } else if (map["file"] != null) {
        return TransfereData(
            currentTransferedItemIndex: map["itemIndex"],
            fileBase64: map["file"]);
      } else {
        throw "Unknown data shape";
      }
    });
  }

  static Future startSendingProcess(List<Uint8List> files) async {
    List<Map<String, String>> filesMap = [];
    for (var file in files) {
      var dateTime = DateTime.now()
          .toUtc()
          .toIso8601String()
          .replaceAll("-", "_")
          .replaceAll(":", "_");
      filesMap.add(
          {"name": "$dateTime.jpg", "base64StringFile": base64.encode(file)});
    }

    await _channel.invokeMethod("setData", {"transferredFiles": filesMap});

    // await discoverPeers;
  }

  static Future<String?> connectToDevice(Device device) async {
    var result = await _channel.invokeMethod("connect", {
      "name": device.name,
      "address": device.address,
      "type": device.type,
      "status": device.status
    });
    return result;
  }

  static Future<String?> cancelConnection() async {
    var result = await _channel.invokeMethod("cancelConnect");

    return result;
  }
}
