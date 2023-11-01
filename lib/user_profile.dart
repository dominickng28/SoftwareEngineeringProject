import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'home_feed.dart';
import 'user.dart';
import 'search.dart';

class MyUserProfilePage extends StatefulWidget {
  const MyUserProfilePage(
      {Key? key,
      required this.title,
      required this.userID,
      required this.profileUserID})
      : super(key: key);
  final String title;
  final String userID;
  final String profileUserID;

  @override
  State<MyUserProfilePage> createState() => _MyUserProfilePageState();
}

class _MyUserProfilePageState extends State<MyUserProfilePage> {
  User? userProfile;

  void followButton(User user, int followuserID) {
    user.addFollowing(followuserID);
    // database.getUser(followuserID).addFollower(user.getID());
  }

  void unfollowButton(User user, int followuserID) {
    user.removeFollowing(followuserID);
    // database.getUser(followuserID).removeFollower(user.getID());
  }

  Future<void> fetchUserData() async {
    // Accessing Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // get profile page owner user details
    final userDocument = await firestoreInstance
        .collection('users')
        .doc(widget.profileUserID)
        .get();

    if (userDocument.exists) {
      // Create a profile page owner instance from Firestore data
      userProfile = User.fromFirestore(userDocument, widget.profileUserID);
      if (widget.profileUserID != widget.userID) {
        // get viewer user details and create instance
        final userViewerDocument = await firestoreInstance
            .collection('users')
            .doc(widget.userID)
            .get();
        User user = User.fromFirestore(userViewerDocument, widget.userID);
      }
      setState(() {
        // Trigger a rebuild with the fetched user data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchUserData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
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
                      userProfile?.profilePicURL ??
                          "SampleImages/default-user.jpg",
                      width: 100, // Adjust the width as needed
                      height: 100,
                      fit: BoxFit.cover, // Adjust the height as needed
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(userProfile?.firstName ?? "Loading..."),
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
    );
  }
}
