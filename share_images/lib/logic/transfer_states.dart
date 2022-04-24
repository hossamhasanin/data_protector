import 'package:equatable/equatable.dart';

import 'models/device_peer.dart';
import 'models/item_meta_data.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class MetaDataState extends TransferState {
  final List<TransferItemMetaData> files;
  final int totalSize;

  const MetaDataState({required this.files, required this.totalSize});

  @override
  List<Object?> get props => [files];
}

class ConnectedState extends TransferState {
  final DevicePeer device;

  const ConnectedState({required this.device});

  @override
  List<Object?> get props => [device];
}

class TransferingState extends TransferState {
  final int currentTransferedItemIndex;
  final int transferedBytes;

  const TransferingState(
      {required this.currentTransferedItemIndex,
      required this.transferedBytes});

  @override
  List<Object?> get props => [
        currentTransferedItemIndex,
        transferedBytes,
      ];
}

class ReceivedFileState extends TransferState {
  final int currentTransferedItemIndex;
  final String fileBase64;

  const ReceivedFileState(
      {required this.fileBase64, required this.currentTransferedItemIndex});

  @override
  List<Object?> get props => [fileBase64, currentTransferedItemIndex];
}

class FailedState extends TransferState {}
