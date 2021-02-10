import 'package:base/models/user.dart';

abstract class AuthDataSource {
  Future<void> login(String email, String password);
  Future<String> signup(String username, String email, String password);
  Future<void> createUserInDatabase(User user);
  Future<void> updateUserData(User user);
  Future<void> setEncryptionKey(String key);
  Future<String> getEncryptionKey();
  bool isLogedIn();
  Future<void> logOut();
  Stream<User> get userData;
}
