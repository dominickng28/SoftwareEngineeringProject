import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Post {
  String imageUrl;
  String caption;
  DateTime date;
  String username;
  int likeCount;
  final String _postid;
  String embed;
  String pfp;
  String userID;
  Post(this.username, this.pfp, this._postid, this.userID, this.caption,
      this.embed, this.date, this.likeCount, this.imageUrl);

  factory Post.fromFirestore(DocumentSnapshot document, String postid) {
    final data = document.data() as Map<String, dynamic>;

    final date = (data['timestamp'] as Timestamp).toDate();

    // Assign other properties from Firestore data
    final post = Post(
        data['username'],
        data['pfp'] ??
            'lib/assets/default-user.jpg', // Use a default value if 'pfp' is null
        postid,
        data['userID'],
        data['caption'],
        data['embed'],
        date,
        data['likecount'],
        data['imageUrl']);

    return post;
  }
}
