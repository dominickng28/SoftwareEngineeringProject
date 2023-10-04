class User {
  /// A class representing a user. userID is immutable.

  String firstName;
  String lastName;
  String username;
  String __email;
  String __password;
  String profilePicURL = "";
  String userBio = "";
  int streaks = 0;

  final int userID;
  
  List<int> followerList = [];
  List<int> followingList = [];

  // list with the ID of each post created by user
  List<int> postList = [];
  
  // default constructor
  User(this.firstName, this.lastName, this.userID, this.username, this.__email, this.__password);
  
  // constructor for sample cases only
  User.withDetails(this.firstName, this.lastName, this.userID, this.username, this.__email, this.__password, 
  this.followerList, this.followingList, this.postList);
}

// A sample list of users to play with.
var SAMPLE_USER = [
  User("John", "Wunder", 123456789, "JohnW2", "JohnW2@gmail.com", "P@ssword"),
  User("Bob", "Reed", 222222222, "BobR55", "BobR55@gmail.com", "Password1"),
  User("Claire", "deluna", 186918691, "Cdel", "Cdel@gmail.com", "PASSWORD3"),
];
