import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String name;
  final int size;
  final String file;
  final Uint8List? image;
  final int progress;

  const Item(
      {required this.name,
      required this.size,
      required this.file,
      required this.image,
      required this.progress});

  @override
  List<Object?> get props => [name, size, file, progress];

  // create factory constructor to initialize item with emty values
  factory Item.empty() {
    return const Item(
      name: '',
      size: 0,
      image: null,
      file: '',
      progress: 0,
    );
  }

  // create function to copy this object
  Item copy({
    String? name,
    int? size,
    String? file,
    Uint8List? image,
    int? progress,
  }) {
    return Item(
      name: name ?? this.name,
      size: size ?? this.size,
      image: image ?? this.image,
      file: file ?? this.file,
      progress: progress ?? this.progress,
    );
  }
}
