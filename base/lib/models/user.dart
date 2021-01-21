import 'package:equatable/equatable.dart';

class User extends Equatable {
  String id;
  String name;
  String email;
  String encryptionKey;

  User({this.id, this.email, this.encryptionKey, this.name});

  @override
  List<Object> get props => [id, email, encryptionKey, name];

  Map<String , dynamic> toDocument() {
    return {
      "id": this.id,
      "name": this.name,
      "email": this.email,
      "encryptionKey": this.encryptionKey
    };
  }
}
