import 'package:base/base.dart';
import 'package:data_protector/data/user/user_supplier.dart';
import 'package:set_user/logic/datasource.dart';

class SetUserDataSourceImpl implements SetUserDataSource {

  final UserSupplier _userSupplier;

  SetUserDataSourceImpl(this._userSupplier);

  @override
  Future<bool> hasDataSet() async {
    final user = await _userSupplier.getUser();
    return user != null;
  }

  @override
  Future<bool> setUser(String username, String secretKey) {
    try {
      _userSupplier.cacheUser(User(encryptionKey: secretKey,name:  username));
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

}