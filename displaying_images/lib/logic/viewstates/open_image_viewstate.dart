import 'dart:typed_data';

class OpenImageViewState {
  final Uint8List currentImageBytes;
  final Uint8List thumbImageBytes;
  final String error;

  OpenImageViewState({
    required this.currentImageBytes,
    required this.thumbImageBytes,
    required this.error,
  });

  factory OpenImageViewState.initial() {
    return OpenImageViewState(
      currentImageBytes: Uint8List.fromList([]),
      thumbImageBytes: Uint8List.fromList([]),
      error: "",
    );
  }

  // create a copy method
  OpenImageViewState copy({
    Uint8List? currentImageBytes,
    Uint8List? thumbImageBytes,
    String? error,
  }) {
    return OpenImageViewState(
      currentImageBytes: currentImageBytes ?? this.currentImageBytes,
      thumbImageBytes: thumbImageBytes ?? this.thumbImageBytes,
      error: error ?? this.error,
    );
  }

}
