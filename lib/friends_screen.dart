import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:live4you/friend.dart';
import 'package:live4you/friend_service.dart';
import 'post.dart';
import 'user.dart';
import 'user_data.dart';
import 'camera_screen.dart';
import 'package:live4you/profile_screen.dart';

class MyFriends extends StatelessWidget {
  const MyFriends({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
        flexibleSpace: const Padding(
          padding: EdgeInsets.only(
            top: 30.0,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(249, 253, 208, 149),
      body: MyFriendsList(),
    );
  }
}

class MyFriendsList extends StatefulWidget{
  @override
  _MyFriendsListState createState() => _MyFriendsListState();
}

class _MyFriendsListState extends State<MyFriendsList> {
  final UserData userData = UserData(FirebaseFirestore.instance);
  final FriendService _friendService = FriendService();
  List<Friend> friendsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  void fetchFriends() async {
    try{
      // Fetch friends list
      await userData.populateFriendsList();
      List<String>? friendList = UserData.friends;

      // Access Firestore instance
      final firestoreInstance = FirebaseFirestore.instance;

      // Fetch all friends
      QuerySnapshot querySnapshot = await firestoreInstance
          .collection('users')
          .where('username', whereIn: friendList)
          .get();

      // Convert each document to a Friend object and add it to the friend list
      List<Friend> allFriends = querySnapshot.docs
          .map((doc) => Friend.fromFirestore(doc))
          .toList();
        setState(() {
          friendsList = allFriends;
          isLoading = false;
        });
    } catch (error) {
      print('Error fetching friends: $error');
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
        : friendsList.isEmpty
            ? Center(child: Text("No friends yet..."))
            : ListView.builder(
                itemCount: friendsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return FriendBar(friend: friendsList[index]);
                },
              );
  }
    
}

  class FriendBar extends StatelessWidget{
    final Friend friend;
  
    const FriendBar({required this.friend});

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyUserProfilePage(profileUserName: friend.username, title: '',),
          ));
        },
        child: Container(color: const Color.fromARGB(249, 253, 208, 149),
      child: Column(
        children: [
          ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(friend.pfp),
              ),
              title: Text(friend.username),
              ),
          
          Container(
              height: 2.0,
              color: Color.fromARGB(248, 172, 113, 36)),
        ],
      ),));
    }
      
      
  }