import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUsernameExists(String username) async {
    final querySnapshot =
        await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> checkUsernameAdminExists(String username) async {
    final querySnapshot =
        await _firestore
            .collection('admin')
            .where('username', isEqualTo: username)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> checkEmailAdminExists(String email) async {
    final querySnapshot =
        await _firestore
            .collection('admin')
            .where('email', isEqualTo: email)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> checkEmailExists(String email) async {
    final querySnapshot =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }
}
