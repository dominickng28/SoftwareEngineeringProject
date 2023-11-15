import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String username;
  String pfp;
  Friend(this.username, this.pfp);



  factory Friend.fromFirestore(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    // Assign other properties from Firestore data
    final friend = Friend(
        data['username'],
        data['pfp'] ??
            'lib/assets/default-user.jpg', // Use a default value if 'pfp' is null
        );

    return friend;
  }
}
