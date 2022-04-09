import 'package:equatable/equatable.dart';

class DataException extends Equatable implements Exception {
  final String message;
  final String code;

  DataException(this.message, this.code);

  @override
  List<Object?> get props => [message, code];
}
