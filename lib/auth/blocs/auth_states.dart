import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitAuth extends AuthState {}

class LoggedIn extends AuthState {
  bool didnotCompleteSignup;
  LoggedIn({required this.didnotCompleteSignup});
}

class SignedUp extends AuthState {}

class Authenticating extends AuthState {}

class AuthError extends AuthState {
  String error;
  AuthError({required this.error});
  @override
  List<Object> get props => [error];
}

class AddingSettings extends AuthState {}

class AddSettingsError extends AuthState {
  String error;
  AddSettingsError({required this.error});
  @override
  List<Object> get props => [error];
}

class AddedSettings extends AuthState {}
