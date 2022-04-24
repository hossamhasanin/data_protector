import 'package:equatable/equatable.dart';
import 'package:wifi_p2p/device.dart';
import 'package:wifi_p2p/item_meta_data.dart';

class TransfereData extends Equatable {
  final int? currentTransferedItemIndex;
  final bool? transfereFaild;
  final int? transferedBytes;
  final List<ItemMetaData>? filesMetaData;
  final int? totalBytes;
  final Device? thisDevice;
  final String? fileBase64;

  const TransfereData(
      {this.thisDevice,
      this.currentTransferedItemIndex,
      this.transfereFaild,
      this.transferedBytes,
      this.filesMetaData,
      this.fileBase64,
      this.totalBytes});

  @override
  List<Object?> get props => [
        currentTransferedItemIndex,
        transfereFaild,
        transferedBytes,
        fileBase64,
        totalBytes,
        filesMetaData,
      ];
}
