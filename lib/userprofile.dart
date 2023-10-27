import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'home_feed.dart';
import 'user.dart';
import 'search.dart';

class MyUserProfilePage extends StatefulWidget {
  const MyUserProfilePage({Key? key, required this.title, required this.userID, required this.profileUserID}) : super(key: key);
  final String title;
  final String userID;
  final String profileUserID;

  @override
  State<MyUserProfilePage> createState() => _MyUserProfilePageState();
}

class _MyUserProfilePageState extends State<MyUserProfilePage> {
  User? userProfile;
  bool isFollowing = false;

  void followButton(User userProfile) async {
    final firestoreInstance = FirebaseFirestore.instance;
    if (!userProfile.isFollowedBy(widget.userID)) {
    firestoreInstance.collection('users').doc(widget.profileUserID).update({
      'followerList': FieldValue.arrayUnion([widget.userID]),
    });
    firestoreInstance.collection('users').doc(widget.userID).update({
      'followingList': FieldValue.arrayUnion([widget.profileUserID]),
    });
    setState(() {
      // Trigger a rebuild with the fetched user data
      isFollowing = userProfile.isFollowedBy(widget.userID);
      });
    }
    else 
    {return;}
  }

  void unfollowButton(User userProfile) async {
    final firestoreInstance = FirebaseFirestore.instance;
    if (userProfile.isFollowedBy(widget.userID)) {
    firestoreInstance.collection('users').doc(widget.profileUserID).update({
      'followerList': FieldValue.arrayRemove([widget.userID]),
    });
    firestoreInstance.collection('users').doc(widget.userID).update({
      'followingList': FieldValue.arrayRemove([widget.profileUserID]),
    });
    setState(() {
      // Trigger a rebuild with the fetched user data
      isFollowing = userProfile.isFollowedBy(widget.userID);
      });
    }
    else 
    {return;}
  }

    Future<void> fetchUserData() async {
    // Accessing Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // get profile page owner user details
    final userDocument = await firestoreInstance.collection('users').doc(widget.profileUserID).get();

    if (userDocument.exists) {
      // Create a profile page owner instance from Firestore data
      userProfile = User.fromFirestore(userDocument, widget.profileUserID);
      setState(() {
        // Trigger a rebuild with the fetched user data
        isFollowing = userProfile!.isFollowedBy(widget.userID);
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
                        userProfile?.profilePicURL ?? "SampleImages/default-user.jpg",
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
                        Visibility(
                          visible: widget.profileUserID != widget.userID,
                          child: ElevatedButton(
                            onPressed: () {
                            if (isFollowing){
                              unfollowButton(userProfile!);
                            }
                            else{
                              followButton(userProfile!);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return isFollowing ? Colors.grey : Colors.green;
                              },
                            ),
                          ),
                          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                    )
                    ]
                  ),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text('User Profile Content'),
            )
          ],
      ),
      floatingActionButton: widget.userID != widget.profileUserID? null: FloatingActionButton(
        onPressed: () {
          // Add a create post function
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          // Handle navigation based on the selected tab
          if (index == 0) {
            // Replace with your navigation logic to the word page
            Navigator.push(
              context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(title: 'Words', userID: widget.userID),
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
                builder: (context) => MySearch(title: 'Search', userID: widget.userID),
              ),
            );
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyUserProfilePage(title: 'User Profile', userID: widget.userID, profileUserID: widget.userID),
              ),
            );
          }
        },
      ),
    );
  }
}