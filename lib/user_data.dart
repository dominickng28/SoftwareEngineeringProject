import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  static String userName = "Nobody"; // Static variable to store the UID
  static List<String>? friends; // Static variable to store the friends list
  final FirebaseFirestore firestore; // Instance of Firestore

  UserData(this.firestore); // Constructor

  Future<void> populateFriendsList(profile) async {
    // Get the current user's username
    String? username;
    if (profile == null) {
      username = UserData.userName;
    } else {
      username = profile;
    }

    // Get the document reference for the current user
    DocumentReference<Map<String, dynamic>> userDoc =
        firestore.collection('users').doc(username);

    // Get the current user's document
    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDoc.get();

    // Check if the document exists and if the friends field exists in the document
    if (userSnapshot.exists) {
      Map<String, dynamic>? data = userSnapshot.data();
      if (data != null && data.containsKey('friends')) {
        // Get the friends field from the document
        List<dynamic> friends = data['friends'];

        // Store the friends list in UserData
        UserData.friends = List<String>.from(friends);
      } else {
        // If the friends field doesn't exist, initialize it as an empty list
        UserData.friends = [];
      }
    } else {
      // If the document doesn't exist, initialize friends as an empty list
      UserData.friends = [];
    }
  }
}
