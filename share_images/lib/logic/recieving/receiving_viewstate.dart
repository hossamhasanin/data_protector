import 'package:share_images/logic/models/device_peer.dart';
import 'package:share_images/logic/item.dart';

class ReceivingViewState {
  final List<DevicePeer> devices;
  final DevicePeer selectedDevice;
  final bool isConnectedToSender;
  final String senderTringToConnectWith;
  final bool isDiscoveringDevices;
  final List<Item> files;
  final bool doneReceiving;
  final bool dataCouldNotBeReceived;

  // create constructor
  ReceivingViewState({
    required this.devices,
    required this.selectedDevice,
    required this.isConnectedToSender,
    required this.senderTringToConnectWith,
    required this.files,
    required this.isDiscoveringDevices,
    required this.dataCouldNotBeReceived,
    required this.doneReceiving,
  });

  // create factory constructor to initialize item with emty values
  factory ReceivingViewState.initial() {
    return ReceivingViewState(
        devices: [],
        selectedDevice: DevicePeer.empty(),
        isConnectedToSender: false,
        senderTringToConnectWith: "",
        files: [],
        isDiscoveringDevices: false,
        doneReceiving: false,
        dataCouldNotBeReceived: false);
  }

  ReceivingViewState copy(
      {List<DevicePeer>? devices,
      DevicePeer? selectedDevice,
      bool? isConnectedToSender,
      String? senderTringToConnectWith,
      List<Item>? files,
      bool? isDiscoveringDevices,
      bool? doneReceiving,
      bool? dataCouldNotBeReceived}) {
    return ReceivingViewState(
        devices: devices ?? this.devices,
        selectedDevice: selectedDevice ?? this.selectedDevice,
        isDiscoveringDevices: isDiscoveringDevices ?? this.isDiscoveringDevices,
        isConnectedToSender: isConnectedToSender ?? this.isConnectedToSender,
        senderTringToConnectWith:
            senderTringToConnectWith ?? this.senderTringToConnectWith,
        files: files ?? this.files,
        doneReceiving: doneReceiving ?? this.doneReceiving,
        dataCouldNotBeReceived:
            dataCouldNotBeReceived ?? this.dataCouldNotBeReceived);
  }
}
