import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Post {
  String caption;
  String date;
  String username;
  int likeCount;
  final String _postid;
  String embed;
  var userID;
  Post(this.username, this._postid, this.userID, this.caption, this.embed, this.date,
      this.likeCount);
  
  factory Post.fromFirestore(DocumentSnapshot document, String postid) {
    final data = document.data() as Map<String, dynamic>;

    // Assign other properties from Firestore data
    final post = Post(
      data['username'],
      postid,
      data['userID'],
      data['caption'],
      data['embed'],
      data['date'],
      data['likeCount']
    );

    return post;
  }
}

