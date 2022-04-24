import 'package:equatable/equatable.dart';

class DevicePeer extends Equatable {
  final String name;
  final String address;
  final String type;
  final int status;

  const DevicePeer(
      {required this.name,
      required this.address,
      required this.type,
      required this.status});

  // create factory constructor to initialize item with emty values
  factory DevicePeer.empty() {
    return const DevicePeer(
      name: '',
      address: '',
      type: '',
      status: 0,
    );
  }

  @override
  List<Object?> get props => [name, address, type, status];
}
