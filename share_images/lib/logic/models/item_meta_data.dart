import 'package:equatable/equatable.dart';

class TransferItemMetaData extends Equatable {
  final String name;
  final int size;

  const TransferItemMetaData({required this.name, required this.size});

  @override
  List<Object?> get props => [
        name,
        size,
      ];
}
