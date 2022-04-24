import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String name;
  final String address;
  final String type;
  final int status;

  Device({
    required this.name,
    required this.address,
    required this.type,
    required this.status
  });

  @override
  List<Object?> get props => [
    name,
    address,
    type,
    status
  ];
}