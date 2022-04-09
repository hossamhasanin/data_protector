import 'package:base/base.dart';

abstract class UserSupplier{
  Future cacheUser(User user);
  Future<User?> getUser();
  User? get user;
}