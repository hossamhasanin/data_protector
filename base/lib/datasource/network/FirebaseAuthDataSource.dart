import 'package:base/Constants.dart';
import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:base/models/user.dart' as U;

class FirebaseAuthDataSource implements AuthDataSource {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<String> signup(String username, String email, String password) async{
    var signup = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return Future.value(signup.user.uid);
  }

  @override
  Future<void> createUserInDatabase(U.User user) {
    return _firestore
        .collection(USERS_COLLECTION)
        .doc(user.id)
        .set(user.toDocument());
  }

  @override
  Future<void> updateUserData(U.User user) {
    return _firestore
        .collection(USERS_COLLECTION)
        .doc(user.id)
        .update(user.toDocument());
  }

  @override
  Future<void> setEncryptionKey(String key) {
    return _firestore
        .collection(USERS_COLLECTION)
        .doc(_auth.currentUser.uid)
        .update({"encryptionKey": key});
  }

  @override
  Future<String> getEncryptionKey() async {
    final user = await _firestore
        .collection(USERS_COLLECTION)
        .doc(_auth.currentUser.uid)
        .get();
    return Future.value(user.data()["encryptionKey"]);
  }

  @override
  bool isLogedIn() {
    return _auth.currentUser != null;
  }

  @override
  Future<void> logOut() {
    return _auth.signOut();
  }
}
