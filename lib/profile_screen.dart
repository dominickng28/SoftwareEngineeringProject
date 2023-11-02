import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:live4you/home_feed.dart';
import 'user.dart';
import 'user_data.dart';

class MyUserProfilePage extends StatefulWidget {
  const MyUserProfilePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<MyUserProfilePage> createState() => _MyUserProfilePageState();
}

class _MyUserProfilePageState extends State<MyUserProfilePage> {
  User? userProfile;
  bool isFriend = false;

  void addFriend(User userProfile) async {
    final firestoreInstance = FirebaseFirestore.instance;
    if (!userProfile.isFriend()) {
      firestoreInstance.collection('users').doc().update({
        'friendsList': FieldValue.arrayUnion([]),
      });
      firestoreInstance.collection('users').doc().update({
        'friendsList': FieldValue.arrayUnion([]),
      });
      setState(() {
        // Trigger a rebuild with the fetched user data
        isFriend = userProfile.isFriend();
      });
    } else {
      return;
    }
  }

  void removeFriend(User userProfile) async {
    final firestoreInstance = FirebaseFirestore.instance;
    if (userProfile.isFriend()) {
      firestoreInstance.collection('users').doc().update({
        'friendsList': FieldValue.arrayRemove([]),
      });
      firestoreInstance.collection('users').doc().update({
        'friendsList': FieldValue.arrayRemove([]),
      });
      setState(() {
        // Trigger a rebuild with the fetched user data
        isFriend = userProfile.isFriend();
      });
    } else {
      return;
    }
  }

  Future<void> fetchUserData() async {
    // Accessing Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // get profile page owner user details
    final userDocument = await firestoreInstance
        .collection('users')
        .doc(UserData.userName)
        .get();

    if (userDocument.exists) {
      // Create a profile page owner instance from Firestore data
      userProfile = User.fromFirestore(userDocument, UserData.userName);
      setState(() {
        // Trigger a rebuild with the fetched user data
        isFriend = userProfile!.isFriend();
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
                    child: userProfile?.profilePicURL == null ||
                            userProfile?.profilePicURL ==
                                'lib/assets/default-user.jpg'
                        ? Image.asset(
                            'lib/assets/default-user.jpg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            userProfile!.profilePicURL,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 20.0),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(userProfile?.firstName ?? "Loading..."),
                        const SizedBox(height: 20.0),
                        Visibility(
                          visible: true,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isFriend) {
                                removeFriend(userProfile!);
                              } else {
                                addFriend(userProfile!);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  return isFriend ? Colors.grey : Colors.green;
                                },
                              ),
                            ),
                            child:
                                Text(isFriend ? 'Remove Friend' : 'Add Friend'),
                          ),
                        )
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyFeed(title: "Home"),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
