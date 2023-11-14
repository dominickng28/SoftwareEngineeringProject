import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:live4you/home_feed.dart';
import 'user.dart';
import 'user_data.dart';
import 'post.dart';
import 'home_feed.dart';
import 'camera_screen.dart';
import 'friend_service.dart';

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
    if (username != null){
      profile = username;
    }
    final userDocument = await firestoreInstance
      .collection('users')
      .doc(profile)
      .get();
    if (userDocument.exists) {
      // Create a profile page owner instance from Firestore data
      userProfile = User.fromFirestore(userDocument, profile);
    if (mounted) {
      setState(() {
        // Trigger a rebuild with the fetched user data
        isFriend = userProfile!.isFriend();
        requestSent = userProfile!.receivedRequests.contains(UserData.userName);
      });
    }
  }
}

  void fetchUserPostData({String? username}) async {
    final firestoreInstance = FirebaseFirestore.instance;
    String profile = UserData.userName;
    if (username != null){
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

  @override
  Widget build(BuildContext context) {
    fetchUserData(username: widget.profileUserName);
    fetchUserPostData(username: widget.profileUserName);
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 60.0), // Adjust the top padding value to lower the image
        child: Center(
          child: Image.asset(
            'lib/assets/Live4youWhite.png', // Replace 'lib/assets/Live4youWhite.png' with your image path
            height: 120, // Adjust the height of the image
            width: 130, // Adjust the width of the image
          ),
        ),
      ),
    ),

      body: Column(
        children: <Widget> [
          // Code for the Profile Banner
Container(
  color: Colors.grey,
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row( // Wrap the Column in a Row // Separates the children
      children: <Widget>[
        ClipOval(
          child: userProfile?.profilePicURL == null ||
              userProfile?.profilePicURL == 'lib/assets/default-user.jpg'
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
            Text(userProfile?.username ?? "Loading User"),
            const SizedBox(height: 20.0),
            Visibility(
              visible: widget.profileUserName != null && widget.profileUserName != UserData.userName,
              child: ElevatedButton(
                onPressed: () {
                  if (requestSent) {
                    _friendService.cancelFriendRequest(
                      UserData.userName, userProfile!.username);
                  }
                  else if (isFriend) {
                    _friendService.removeFriend(
                      UserData.userName, userProfile!.username);
                  } else {
                      if(userProfile!.sentRequests.contains(UserData.userName)){
                       _friendService.acceptFriendRequest(
                        UserData.userName, userProfile!.username);
                        return;
                     }
                      _friendService.sendFriendRequest(
                        UserData.userName, userProfile!.username);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (widget.profileUserName != null && widget.profileUserName != UserData.userName){
                        if (userProfile?.receivedRequests.contains(UserData.userName) == true){
                          return Colors.grey;
                        }
                      }
                      return isFriend ? Colors.grey : Colors.green;
                    },
                  ),
                ),
                child:
                  Container(
                    width: 100,
                    child: Center(
                      child: Text(requestSent ? 'Cancel Request' : isFriend ? 'Remove Friend' : 'Add Friend')
                    ),
                  )
              ),
            )
          ],
        ),
        Container(
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // Add any logic or navigation you need when the button is pressed
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                  ),
                  child: Text('Followers'),
                ),
                SizedBox(width: 8.0),
                FutureBuilder<int>(
                  future: followerCount,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
      floatingActionButton: userProfile?.username != UserData.userName? null: FloatingActionButton(
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