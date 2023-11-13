import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

class User {
  /// A class representing a user. userID is immutable.

  String username;
  String profilePicURL = "lib/assets/default-user.jpg";
  String userBio = "";
  int streaks = 0;

  final String userID;

  List<String> friendsList = [];
  List<String> receivedRequests = [];
  List<String> sentRequests = [];
  // list with the ID of each post created by user
  List<String> postList = [];

  // default constructor
  User(this.userID, this.username);

  // constructor for sample cases only
  User.withDetails(this.userID, this.username,
      this.profilePicURL, this.friendsList, this.postList);

  String getUserID() {
    return userID;
  }

  List<String> getPostlist() {
    return postList;
  }

  List<String> getFriendslist() {
    return friendsList;
  }

  void addFriend(friendID) {
    friendsList.add(friendID);
    return;
  }

  void removeFriend(friendID) {
    friendsList.remove(friendID);
    return;
  }

  bool isFriend() {
    return friendsList.contains(UserData.userName);
  }

  factory User.fromFirestore(DocumentSnapshot document, String userName) {
    final data = document.data() as Map<String, dynamic>;

    // Assign other properties from Firestore data
    final user = User(
      data['uid'],
      userName,
    );

    user.profilePicURL = data['profilePicURL'] ?? "lib/assets/default-user.jpg";
    user.userBio = data['userbio'] ?? "";
    user.streaks = data['streaks'] ?? 0;
    if (data['received_requests'] != null) {
      user.receivedRequests = data['received_requests'].cast<String>() ?? [];
    }
    if (data['sent_requests'] != null) {
      user.sentRequests = data['sent_requests'].cast<String>() ?? [];
    }
    if (data['friends'] != null) {
      user.friendsList = List<String>.from(data['friends']);
    }
    if (data['post_list'] != null) {
      user.postList = data['post_list'].cast<String>() ?? [];
    }
    return user;
  }

  /* UNUSED/OUTDATED CODE
  static Future<List<String>> fetchFriendsList(String userID) async {
    List<String> friendsList = [];
    try {
      final firestoreInstance = FirebaseFirestore.instance;
      final userDocument =
          await firestoreInstance.collection('users').doc(userID).get();

      if (userDocument.exists) {
        final userData = userDocument.data() as Map<String, dynamic>;
        final friendsListData = userData['friends'];

        if (friendsListData != null && friendsListData is List) {
          friendsList = List<String>.from(friendsListData);
        }
      }
    } catch (e) {
      // Handle any errors, e.g., print or log the error
      print('Error fetching friends list: $e');
    }

    return friendsList;
  }

  static Future<List<String>> fetchPostList(String userID) async {
    List<String> postList = [];
    try {
      final firestoreInstance = FirebaseFirestore.instance;
      final userDocument =
          await firestoreInstance.collection('users').doc(userID).get();

      if (userDocument.exists) {
        final userData = userDocument.data() as Map<String, dynamic>;
        final postListData = userData['postList'];

        if (postListData != null && postListData is List) {
          postList = List<String>.from(postListData);
        }
      }
    } catch (e) {
      // Handle any errors, e.g., print or log the error
      print('Error fetching post list: $e');
    }

    return postList;
  }
  */
}
