//import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:live4you/friend.dart';
import 'package:live4you/friend_service.dart';
import 'package:live4you/main.dart';
//import 'post.dart';
//import 'user.dart';
import 'user_data.dart';
//import 'camera_screen.dart';
//import 'package:live4you/profile_screen.dart';

class MyFriends extends StatelessWidget {
  const MyFriends({super.key, required this.title, this.profileUsername});

  final String title;
  final String? profileUsername;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 23,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        flexibleSpace: const Padding(
          padding: EdgeInsets.only(
            top: 30.0,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: MyFriendsList(profileUsername: profileUsername),
    );
  }
}

class MyFriendsList extends StatefulWidget {
  final String? profileUsername;
  const MyFriendsList({super.key, required this.profileUsername});

  @override
  MyFriendsListState createState() => MyFriendsListState();
}

class MyFriendsListState extends State<MyFriendsList> {
  final UserData userData = UserData(FirebaseFirestore.instance);
  //final FriendService _friendService = FriendService();
  List<Friend> friendsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends(widget.profileUsername);
  }

  void fetchFriends(profileUsername) async {
    try {
      // Fetch friends list
      await userData.populateFriendsList(profileUsername);
      List<String>? friendList = UserData.friends;

      // Access Firestore instance
      final firestoreInstance = FirebaseFirestore.instance;

      // Fetch all friends
      QuerySnapshot querySnapshot = await firestoreInstance
          .collection('users')
          .where('username', whereIn: friendList)
          .get();

      // Convert each document to a Friend object and add it to the friend list
      List<Friend> allFriends =
          querySnapshot.docs.map((doc) => Friend.fromFirestore(doc)).toList();
      setState(() {
        friendsList = allFriends;
        isLoading = false;
      });
    } catch (error) {
      //print('Error fetching friends: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child:
                CircularProgressIndicator()) // Show loader while fetching data
        : friendsList.isEmpty
            ? const Center(
                child: Text(
                "No friends yet...",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 23,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ))
            : ListView.builder(
                itemCount: friendsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return FriendBar(friend: friendsList[index]);
                },
              );
  }
}

class FriendBar extends StatelessWidget {
  final Friend friend;
  final FriendService friendService = FriendService(); // Add the FriendService

  FriendBar({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  profile: friend.username,
                  index: 2,
                ),
              ));
        },
        child: Container(
          color: const Color.fromARGB(255, 0, 0, 0),
          child: Column(
            children: [
              ListTile(
                leading: StreamBuilder<String?>(
                  stream:
                      friendService.userProfilePictureStream(friend.username),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    ImageProvider imageProvider;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Use a placeholder image when the profile picture is loading
                      imageProvider =
                          const AssetImage('lib/assets/default-user.jpg');
                    } else if (snapshot.hasError) {
                      imageProvider =
                          const AssetImage('lib/assets/images/error.png');
                    } else {
                      String? profilePictureUrl = snapshot.data;
                      if (profilePictureUrl == null ||
                          profilePictureUrl.isEmpty) {
                        // Use a default profile picture when there's no profile picture
                        imageProvider =
                            const AssetImage('lib/assets/default-user.jpg');
                      } else {
                        // Use NetworkImage when loading an image from a URL
                        imageProvider = NetworkImage(profilePictureUrl);
                      }
                    }
                    return CircleAvatar(
                      backgroundImage: imageProvider,
                    );
                  },
                ),
                title: Text(
                  friend.username,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(height: 2.0, color: const Color.fromARGB(255, 0, 0, 0)),
            ],
          ),
        ));
  }
}
