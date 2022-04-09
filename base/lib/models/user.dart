import 'package:equatable/equatable.dart';

class User extends Equatable {
  String id;
  String name;
  String email;
  String encryptionKey;

  User(
      {required this.id,
      required this.email,
      required this.encryptionKey,
      required this.name});

  factory User.init() {
    return User(id: "", email: "", encryptionKey: "", name: "");
  }

  @override
  List<Object?> get props => [id, email, encryptionKey, name];

  Map<String, dynamic> toDocument() {
    return {
      "id": this.id,
      "name": this.name,
      "email": this.email,
      "encryptionKey": this.encryptionKey
    };
  }
}
