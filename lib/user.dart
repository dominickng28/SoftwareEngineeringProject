import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

class User {
  /// A class representing a user. userID is immutable.

  String firstName;
  String lastName;
  String username;
  String profilePicURL = "lib/assets/default-user.jpg";
  String userBio = "";
  int streaks = 0;

  final String userID;

  List<String> friendsList = [];

  // list with the ID of each post created by user
  List<String> postList = [];

  // default constructor
  User(this.firstName, this.lastName, this.userID, this.username);

  // constructor for sample cases only
  User.withDetails(this.firstName, this.lastName, this.userID, this.username,
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

  factory User.fromFirestore(DocumentSnapshot document, String userID) {
    final data = document.data() as Map<String, dynamic>;

    // Assign other properties from Firestore data
    final user = User(
      data['firstName'],
      data['lastName'],
      userID,
      data['username'],
    );

    user.profilePicURL = data['profilePicURL'] ?? "lib/assets/default-user.jpg";
    user.userBio = data['userBio'] ?? "";
    user.streaks = data['streaks'] ?? 0;

    if (data['friendsList'] != null) {
      user.friendsList = List<String>.from(data['friendsList']);
    }
    if (data['postList'] != null) {
      user.postList = List<String>.from(data['postList']);
    }

    return user;
  }

  static Future<List<String>> fetchFriendsList(String userID) async {
    List<String> friendsList = [];
    try {
      final firestoreInstance = FirebaseFirestore.instance;
      final userDocument =
          await firestoreInstance.collection('users').doc(userID).get();

      if (userDocument.exists) {
        final userData = userDocument.data() as Map<String, dynamic>;
        final friendsListData = userData['friendsList'];

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
}
