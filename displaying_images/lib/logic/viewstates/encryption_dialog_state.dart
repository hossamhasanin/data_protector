import 'package:equatable/equatable.dart';

class EncryptionDialogState extends Equatable {
  final bool encryption;
  final double encryptionProgress;
  final String encryptionError;
  final bool encryptionSuccess;
  final String encryptionSuccessMessage;
  final String encryptionLoadingMessage;

  EncryptionDialogState({
    required this.encryption,
    required this.encryptionSuccess,
    required this.encryptionProgress,
    required this.encryptionLoadingMessage,
    required this.encryptionError,
    required this.encryptionSuccessMessage,
  });

  factory EncryptionDialogState.initial() {
    return EncryptionDialogState(
        encryption: false,
        encryptionProgress: 0,
        encryptionSuccess: false,
        encryptionError: '',
        encryptionSuccessMessage: '',
        encryptionLoadingMessage: "");
  }

  EncryptionDialogState copy({
    bool? encryptionLoading,
    double? encryptionProgress,
    bool? encryptionSuccess,
    String? encryptionError,
    String? encryptionSuccessMessage,
    String? encryptionLoadingMessage,
  }) {
    return EncryptionDialogState(
      encryption: encryptionLoading ?? this.encryption,
      encryptionSuccess: encryptionSuccess ?? this.encryptionSuccess,
      encryptionProgress: encryptionProgress ?? this.encryptionProgress,
      encryptionError: encryptionError ?? this.encryptionError,
      encryptionSuccessMessage:
          encryptionSuccessMessage ?? this.encryptionSuccessMessage,
      encryptionLoadingMessage:
          encryptionLoadingMessage ?? this.encryptionLoadingMessage,
    );
  }

  @override
  List<Object?> get props => [
        encryption,
        encryptionProgress,
        encryptionError,
        encryptionSuccess,
        encryptionSuccessMessage,
        encryptionLoadingMessage,
      ];
}
