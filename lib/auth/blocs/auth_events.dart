import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Login extends AuthEvent {
  final String email;
  final String password;
  Login({this.email, this.password});
  @override
  List<Object> get props => [email, password];
}

class Signup extends AuthEvent {
  final String email;
  final String username;
  final String password;
  Signup({this.email, this.password, this.username});

  @override
  List<Object> get props => [email, password, username];
}

class SetSettings extends AuthEvent {
  final String key;
  SetSettings({this.key});
  @override
  List<Object> get props => [key];
}
