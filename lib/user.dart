class User {
  /// A class representing a user. userID is immutable.

  String firstName;
  String lastName;
  String username;
  final String __email;
  final String __password;
  String profilePicURL = "SampleImages/default-user.jpg";
  String userBio = "";
  int streaks = 0;

  final int userID;

  List<int> followerList = [];
  List<int> followingList = [];

  // list with the ID of each post created by user
  List<int> postList = [];

  // default constructor
  User(this.firstName, this.lastName, this.userID, this.username, this.__email,
      this.__password);

  // constructor for sample cases only
  User.withDetails(
      this.firstName,
      this.lastName,
      this.userID,
      this.username,
      this.__email,
      this.__password,
      this.profilePicURL,
      this.followerList,
      this.followingList,
      this.postList);
  
  int getUserID(){
    return userID;
  }

  List<int> getPostlist(){
    return postList;
  }

  List<int> getFollowerlist(){
    return followerList;
  }

  List<int> getFollowinglist(){
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

  bool isFollowing(int userID){
    bool following = false;
    for (int ID in followerList){
      if (ID == userID) {
        following = true;
        break;
      }
    }
    return following;
  }
}

// A sample list of users to play with.
var sampleUser = [
  User("John", "Wunder", 123456789, "JohnW2", "JohnW2@gmail.com", "P@ssword"),
  User.withDetails("Bob", "Reed", 222222222, "BobR55", "BobR55@gmail.com",
      "Password1", "SampleImages/pfp1.jpg", [186918691], [186918691], [123]),
  User.withDetails("Claire", "deluna", 186918691, "Cdel", "Cdel@gmail.com",
"PASSWORD3", "SampleImages/pfp1.jpg", [222222222], [222222222], [321, 231]),
];
