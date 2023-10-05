class UserLogin { //Creates data class used for login screen
  String username; //Makes Username variable
  String password; // Makes Password variable
  String email; //Makes email variable

  UserLogin({required this.username, required this.password, required this.email}); //Constructor used to define the users login info
} 

// Sample user data
List<UserLogin> sampleUsers = [
  UserLogin(username: "user1", password: "password1", email: "user1@example.com"), //Creating instances using the class
  UserLogin(username: "user2", password: "password2", email: "user2@example.com"),
  UserLogin(username: "user3", password: "password3", email: "user3@example.com"),
];