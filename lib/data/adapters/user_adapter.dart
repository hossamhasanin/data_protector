import 'package:base/base.dart';
import 'package:hive/hive.dart';

class UserAdapter extends TypeAdapter<User>{
  @override
  User read(BinaryReader reader) {
    return User(
        id: reader.read(),
        email: reader.read(),
        encryptionKey: reader.read(),
        name: reader.read()
    );
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..write(obj.id)
      ..write(obj.email)
      ..write(obj.encryptionKey)
      ..write(obj.name);
  }

}