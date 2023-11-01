import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addUserToFirestore(String password, String email, String username) async {
    await _firestore.collection('users').doc(username).set({
      'email': email,
      'username': username,
      'password': password,
      // add other user details here
    });
  }

  Future<String?> getUsernameFromEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['username'];
    } else {
      return null;
    }
  }

Future<bool> checkUsernameExists(String username) async {
  // Convert username to lowercase for a case-insensitive comparison
  username = username.toLowerCase();
  
  // Perform a case-insensitive query
  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  
  return result.docs.isNotEmpty;
}
  Future<String?> getEmailFromUsername(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['email'];
    } else {
      return null;
    }
  }
}