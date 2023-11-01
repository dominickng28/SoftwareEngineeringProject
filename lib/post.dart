import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String caption;
  String date;
  String username;
  int likeCount;
  final String _postid;
  String embed;
  String pfp;
  String userID;
  Post(this.username, this.pfp, this._postid, this.userID, this.caption, this.embed, this.date,
      this.likeCount);

  String getCaption(){
    return caption;
  }
  String getDate(){
    return date;
  }
  String getUsername(){
    return username;
  }
  int getLikeCount(){
    return likeCount;
  }
  String _getPostID(){
    return _postid;
  }
  String getEmbed(){
    return embed;
  }
  String getPfp(){
    return pfp;
  }

factory Post.fromFirestore(DocumentSnapshot document, String _postid){
  final data = document.data() as Map<String, dynamic>;

  final post = Post(
    data['username'],
    data['pfp'],
    _postid,
    data['userID'],
    data['caption'],
    data['embed'],
    data['date'],
    data['likeCount'],
    
    );
    return post;
}

}

var samplePost = [
  Post('John', 'pfp1.jpg', '123', '222222222', "Took a hike!", "hiketrail.jpg", "10/02/2023", 4),
  Post('Bob', 'pfp2.jpeg', '321', '186918691', "Went for a swim!", "pool.jpg", "10/03/2023", 43),
  Post('Clair', 'pfp.jpg', '231', '186918691', "Had a nice walk!", "park.jpg", "10/04/2023", 343),
];