import 'package:flutter/material.dart';
import 'main.dart';
import 'home_feed.dart';
import 'user.dart';

class MyUserProfilePage extends StatefulWidget {
  const MyUserProfilePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyUserProfilePage> createState() => _MyUserProfilePageState();
}

class _MyUserProfilePageState extends State<MyUserProfilePage> {

  var sampleUser = [
  User("John", "Wunder", 123456789, "JohnW2", "JohnW2@gmail.com", "P@ssword"),
  User.withDetails("Bob", "Reed", 222222222, "BobR55", "BobR55@gmail.com",
      "Password1", "SampleImages/pfp1.jpg", [186918691], [186918691], [123]),
  User.withDetails("Claire", "deluna", 186918691, "Cdel", "Cdel@gmail.com",
"PASSWORD3", "SampleImages/pfp1.jpg", [222222222], [222222222], [321, 231]),
];

  void followButton(User user, int followuserID) {
    user.addFollowing(followuserID);
    // database.getUser(followuserID).addFollower(user.getID());
  }

  void unfollowButton(User user, int followuserID) {
    user.removeFollowing(followuserID);
    // database.getUser(followuserID).removeFollower(user.getID());
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: 
        Column(
          children: <Widget>[
            Container(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ClipOval(
                      child: Image.asset(
                        sampleUser[0].profilePicURL,
                        width: 100, // Adjust the width as needed
                        height: 100,
                        fit: BoxFit.cover, // Adjust the height as needed
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(sampleUser[0].firstName),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            // Code to run when the "Follow" button is pressed
                          },
                          child: const Text('Follow'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text('User Profile Content'),
            )
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a create post function
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          // Handle navigation based on the selected tab
          if (index == 0) {
            // Replace with your navigation logic to the search page
            Navigator.push(
              context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(title: 'Words'),
              ),
            );
          } 
          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyFeed(title: 'Homefeed'),
              ),
            );
          } 
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyUserProfilePage(title: 'User Profile'),
              ),
            );
          }
        },
      ),
    );
  }
}