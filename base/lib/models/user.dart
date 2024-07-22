import 'package:equatable/equatable.dart';

class User extends Equatable {
  String name;
  String encryptionKey;

  User({required this.encryptionKey,
      required this.name});

  factory User.init() {
    return User(encryptionKey: "", name: "");
  }

  @override
  List<Object?> get props => [encryptionKey, name];

  Map<String, dynamic> toDocument() {
    return {
      "name": this.name,
      "encryptionKey": this.encryptionKey
    };
  }

  // create a copyWith method
  User copyWith({
    String? name,
    String? encryptionKey,
  }) {
    return User(
      name: name ?? this.name,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }
}
