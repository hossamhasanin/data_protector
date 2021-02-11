import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/encrypt/Encrypt.dart';
import 'package:base/models/user.dart';

class AuthUseCase {
  AuthDataSource _authDataSource;
  Encrypt _encrypt;
  AuthUseCase({AuthDataSource authDataSource, Encrypt encrypt})
      : _encrypt = encrypt,
        _authDataSource = authDataSource;

  Future<String> login(String email, String password) async {
    await _authDataSource.login(email, password);
    return _authDataSource.getEncryptionKey();
  }

  Future<void> signup(String username, String email, String password) async {
    final userId = await _authDataSource.signup(username, email, password);
    final user = User(id: userId, name: username, email: email);
    return _authDataSource.createUserInDatabase(user);
  }

  Future<void> setSettings(String key) {
    String hashedKey = _encrypt.hash(key);
    return _authDataSource.setEncryptionKey(hashedKey);
  }

  Future deleteUser() {
    return _authDataSource.logOut();
  }

  bool isLoggedIn() {
    return _authDataSource.isLogedIn();
  }
}
