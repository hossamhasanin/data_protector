import 'package:base/base.dart';
import 'package:hive/hive.dart';

import 'user_supplier.dart';

class UserSupplierImp extends UserSupplier{

  User? _user;

  @override
  User? get user => _user;

  @override
  Future cacheUser(User user) async {
    _user = user;
    var usersBox = await Hive.openBox<User>("users");
    await usersBox.clear();
    await usersBox.put(0 , user);
  }

  @override
  Future<User?> getUser() async {
    if (_user != null){
      return _user;
    }
    var usersBox = await Hive.openBox<User>("users");
    _user = usersBox.getAt(0);
    return _user;
  }

}