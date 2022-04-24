import 'package:share_images/logic/models/device_peer.dart';
import 'package:share_images/logic/item.dart';

class SendingViewState {
  final bool isConnectedToReciever;
  final List<Item> files;
  final bool doneSending;
  final bool dataCouldNotBeSent;
  final DevicePeer currentDevice;

  SendingViewState({
    required this.isConnectedToReciever,
    required this.files,
    required this.dataCouldNotBeSent,
    required this.currentDevice,
    required this.doneSending,
  });

  factory SendingViewState.initial() {
    return SendingViewState(
      isConnectedToReciever: false,
      files: [],
      dataCouldNotBeSent: false,
      currentDevice: DevicePeer.empty(),
      doneSending: false,
    );
  }

  SendingViewState copy({
    bool? isConnectedToReciever,
    List<Item>? files,
    bool? dataCouldNotBeSent,
    DevicePeer? currentDevice,
    bool? doneSending,
  }) {
    return SendingViewState(
      isConnectedToReciever:
          isConnectedToReciever ?? this.isConnectedToReciever,
      files: files ?? this.files,
      dataCouldNotBeSent: dataCouldNotBeSent ?? this.dataCouldNotBeSent,
      currentDevice: currentDevice ?? this.currentDevice,
      doneSending: doneSending ?? this.doneSending,
    );
  }
}
