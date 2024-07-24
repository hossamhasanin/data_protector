import 'package:base/base.dart';
import 'package:base/encrypt/Encrypt.dart';
import 'package:hive/hive.dart';

import 'user_supplier.dart';

class UserSupplierImp extends UserSupplier{

  User? _user;

  @override
  User? get user => _user;

  final Encrypt encrypt;

  UserSupplierImp(this.encrypt);

  @override
  Future cacheUser(User user) async {
    _user = user;
    _user = _user!.copyWith(encryptionKey: encrypt.hash(_user!.encryptionKey));
    var usersBox = await Hive.openBox<User>("users");
    await usersBox.clear();
    await usersBox.put(0 , _user!);
  }

  @override
  Future<User?> getUser() async {
    if (_user != null){
      return _user;
    }
    var usersBox = await Hive.openBox<User>("users");
    _user = usersBox.isNotEmpty ? usersBox.getAt(0) : null;
    return _user;
  }

}