import 'package:equatable/equatable.dart';

class ItemMetaData extends Equatable {
  final String name;
  final int size;

  const ItemMetaData({required this.name, required this.size});

  @override
  List<Object?> get props => [name, size];
}
