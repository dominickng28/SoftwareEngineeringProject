import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:live4you/friend.dart';
import 'package:live4you/home_feed.dart';
import 'user.dart';
import 'user_data.dart';
import 'post.dart';
import 'home_feed.dart';
import 'camera_screen.dart';
import 'friend_service.dart';
import 'friends_screen.dart';
import 'search.dart';

class MyUserProfilePage extends StatefulWidget {
  final String? profileUserName;

  const MyUserProfilePage({
    super.key,
    required this.title,
    this.profileUserName,
  });
  final String title;

  @override
  State<MyUserProfilePage> createState() => _MyUserProfilePageState();
}

class _MyUserProfilePageState extends State<MyUserProfilePage> {
  User? userProfile;
  bool isFriend = false;
  bool requestSent = false;
  List<Post> posts = [];
  final FriendService _friendService = FriendService();
  late Future<int> followerCount;
  String? userBio;

  @override
  void initState() {
    super.initState();
    followerCount = fetchFollowerCount();
  }

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

  Future<void> fetchUserData({String? username}) async {
    // Accessing Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;
    // get profile page owner user details
    String profile = UserData.userName;
    if (username != null) {
      profile = username;
    }
    final userDocument =
        await firestoreInstance.collection('users').doc(profile).get();
    if (userDocument.exists) {
      // Create a profile page owner instance from Firestore data
      userProfile = User.fromFirestore(userDocument, profile);
      if (mounted) {
        setState(() {
          // Trigger a rebuild with the fetched user data
          isFriend = userProfile!.isFriend();
          requestSent =
              userProfile!.receivedRequests.contains(UserData.userName);
          userBio = userProfile!.userBio;
        });
      }
    }
  }

  void fetchUserPostData({String? username}) async {
    final firestoreInstance = FirebaseFirestore.instance;
    String profile = UserData.userName;
    if (username != null) {
      profile = username;
    }
    QuerySnapshot querySnapshot = await firestoreInstance
        .collection('posts')
        .where('username', isEqualTo: profile)
        .get();

    List<Post> allPostData = querySnapshot.docs
        .map((doc) => Post.fromFirestore(doc, doc.id))
        .toList();

    allPostData.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) {
      setState(() {
        posts = allPostData;
      });
    }
  }
 void _navigateToMySearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MySearch(
          title: 'Search',
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  fetchUserData(username: widget.profileUserName);
  fetchUserPostData(username: widget.profileUserName);

  // Display a default title if the profileUserName is null
  String title = widget.profileUserName ?? 'Profile';

  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),

      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 0, left: 300),
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: widget.profileUserName != null &&
                      widget.profileUserName != UserData.userName,
                  child: IconButton(
                    onPressed: () {
                      if (requestSent) {
                        _friendService.cancelFriendRequest(
                            UserData.userName, userProfile!.username);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Canceled Friend Request')),
                        );
                      } else if (isFriend) {
                        _friendService.removeFriend(
                            UserData.userName, userProfile!.username);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Friend Removed')),
                        );
                      } else {
                        if (userProfile!.sentRequests
                            .contains(UserData.userName)) {
                          _friendService.acceptFriendRequest(
                              UserData.userName, userProfile!.username);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Friend Request Accepted')),
                          );
                          return;
                        }
                        _friendService.sendFriendRequest(
                            UserData.userName, userProfile!.username);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Friend Request Sent')),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (widget.profileUserName != null &&
                              widget.profileUserName != UserData.userName) {
                            if (userProfile?.receivedRequests
                                    .contains(UserData.userName) ==
                                true) {
                              return Colors.white;
                            }
                          }
                          return isFriend ? Colors.white : Colors.white;
                        },
                      ),
                    ),
                    icon: Icon(requestSent
                        ? Icons.person_outline_rounded
                        : isFriend
                            ? Icons.person_remove_rounded
                            : Icons.person_add_alt_1_rounded),
                  ),
                ),
              ],
            ),
          ),
          // Code for the Profile Banner
          Container(
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                // Wrap the Column in a Row // Separates the children
                children: <Widget>[
                  ClipOval(
                    child: userProfile?.profilePicURL == null ||
                            userProfile?.profilePicURL ==
                                'lib/assets/default-user.jpg'
                        ? Image.asset(
                            'lib/assets/default-user.jpg',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            userProfile!.profilePicURL,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 20.0),
                  //Username
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              userProfile?.username ?? "Loading User"),
                          const SizedBox(height: 10),
                          Text(
                            userBio ??
                                '', // Display the user's bio if available
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyFriends(
                                        title: 'Friends',
                                      )),
                            );
                          },
                          child: const Text(
                            "Friends",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(248, 1, 31,
                                  57), // Change this to your preferred color
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        FutureBuilder<int>(
                          future: followerCount,
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                snapshot.data.toString(),
                                style: TextStyle(fontSize: 16.0),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Code for the Posts
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return PostCard(post: posts[index]);
              },
            ),
          ),
        ],
      ),
      // Code for the create post button
      floatingActionButton: userProfile?.username != UserData.userName
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final cameras = await availableCameras();
                final firstCamera = cameras.first;

                final didCreatePost = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(camera: firstCamera),
                  ),
                );

                if (didCreatePost == true) {
                  fetchUserPostData(); // Refresh the feed if a new post was created
                }
              },
              tooltip: 'Camera',
              child: const Icon(Icons.camera_alt),
            ),
    );
  }
}

Future<int> fetchFollowerCount() async {
  final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(UserData.userName)
      .get();

  if (userSnapshot.exists) {
    final userData = userSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      // Check if the 'friends' field exists in the document
      final friendsData = userData['friends'];

      if (friendsData != null && friendsData is List<dynamic>) {
        // Retrieve the list of friends and return the length
        int followerCount = friendsData.length;
        return followerCount;
      }
    }
  } else {
    // User document doesn't exist
    print('Error: User document does not exist.');
    return 0;
  }
  return 0;
}
