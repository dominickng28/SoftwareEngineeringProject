class User {
  /// A class representing a user. userID is immutable.

  String firstName;
  String lastName;
  String _username;
  String _email;
  String __password;
  String userBio = "";
  int streaks = 0;

  // userID is marked final so it is immutable after instantiation.
  final int userID;
  
  // followerList will contain the userID of each followers
  List<int> followerList = [];

  // followingList will contain the userID of everyone the user is following
  List<int> followingList = [];
  
  // profile picture variable will be included later on
  User(this.firstName, this.lastName, this.userID, this._username, this._email, this.__password);
}

// A sample list of employees to play with.
var SAMPLE_USER = [
  User("John", "Wunder", 123456789, "JohnW2", "JohnW2@gmail.com", "P@ssword"),
  User("Bob", "Reed", 222222222, "BobR55", "BobR55@gmail.com", "Password1"),
  User("Claire", "deluna", 186918691, "Cdel", "Cdel@gmail.com", "PASSWORD3"),
];
