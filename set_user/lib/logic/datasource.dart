abstract class SetUserDataSource {
  Future<bool> setUser(String username, String secretKey);
  Future<bool> hasDataSet();
}