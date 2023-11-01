import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  /// A class representing a user. userID is immutable.

  String firstName;
  String lastName;
  String username;
  String profilePicURL = "lib/assets/default-user.jpg";
  String userBio = "";
  int streaks = 0;

  final String userID;

  List<String> followerList = [];
  List<String> followingList = [];

  // list with the ID of each post created by user
  List<String> postList = [];

  // default constructor
  User(this.firstName, this.lastName, this.userID, this.username);

  // constructor for sample cases only
  User.withDetails(
      this.firstName,
      this.lastName,
      this.userID,
      this.username,
      this.profilePicURL,
      this.followerList,
      this.followingList,
      this.postList);
  
  String getUserID(){
    return userID;
  }

  List<String> getPostlist(){
    return postList;
  }

  List<String> getFollowerlist(){
    return followerList;
  }

  List<String> getFollowinglist(){
    return followingList;
  }

  void addFollower(followerID) {
    followerList.add(followerID);
    return;
  }

  void removeFollower(followerID) {
    followerList.remove(followerID);
    return;
  }

    void addFollowing(userID) {
    followingList.add(userID);
    return;
  }

  void removeFollowing(userID) {
    followingList.remove(userID);
    return;
  }

  bool isFollowing(String userID){
    return followingList.contains(userID);
  }

  bool isFollowedBy(String userID){
    return followerList.contains(userID);
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

    if (data['followerList'] != null) {
      user.followerList = List<String>.from(data['followerList']);
    }
    if (data['followingList'] != null) {
      user.followingList = List<String>.from(data['followingList']);
    }
    if (data['postList'] != null) {
      user.postList = List<String>.from(data['postList']);
    }

    return user;
  }

  static Future<List<String>> fetchFollowingList(String userID) async {
    List<String> followingList = [];
    try {
      final firestoreInstance = FirebaseFirestore.instance;
      final userDocument = await firestoreInstance.collection('users').doc(userID).get();

      if (userDocument.exists) {
        final userData = userDocument.data() as Map<String, dynamic>;
        final followingListData = userData['followingList'];

        if (followingListData != null && followingListData is List) {
          followingList = List<String>.from(followingListData);
        }
      }
    } catch (e) {
      // Handle any errors, e.g., print or log the error
      print('Error fetching followingList: $e');
    }

    return followingList;
  }

    static Future<List<String>> fetchPostList(String userID) async {
    List<String> postList = [];
    try {
      final firestoreInstance = FirebaseFirestore.instance;
      final userDocument = await firestoreInstance.collection('users').doc(userID).get();

      if (userDocument.exists) {
        final userData = userDocument.data() as Map<String, dynamic>;
        final postListData = userData['postList'];

        if (postListData != null && postListData is List) {
          postList = List<String>.from(postListData);
        }
      }
    } catch (e) {
      // Handle any errors, e.g., print or log the error
      print('Error fetching followingList: $e');
    }

    return postList;
  }
}

// A sample list of users to play with.
  var sampleUser = [
  User("John", "Wunder", "tCBgXhuZ57gJUfOhyS7X6gdF3sE3", "JohnW2"),
  User.withDetails("Bob", "Reed", "to7UDeMklvPrDDAZqrURwpW6ENf1", "BobR55", "SampleImages/pfp1.jpg", ["CSJTlYeExpS1qMQROeWCnqZEzIF2"], ["CSJTlYeExpS1qMQROeWCnqZEzIF2"], ['123']),
  User.withDetails("Claire", "deluna", "CSJTlYeExpS1qMQROeWCnqZEzIF2", "Cdel", "SampleImages/pfp1.jpg", ["to7UDeMklvPrDDAZqrURwpW6ENf1"], ["to7UDeMklvPrDDAZqrURwpW6ENf1"], ['321', '231']),
];

