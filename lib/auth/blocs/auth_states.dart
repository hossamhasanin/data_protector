import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitAuth extends AuthState {}

class LoggedIn extends AuthState {}

class SignedUp extends AuthState {}

class Authenticating extends AuthState {}

class AuthError extends AuthState {
  String error;
  AuthError({this.error});
  @override
  List<Object> get props => [error];
}

class AddingSettings extends AuthState {}

class AddSettingsError extends AuthState {
  String error;
  AddSettingsError({this.error});
  @override
  List<Object> get props => [error];
}

class AddedSettings extends AuthState {}
