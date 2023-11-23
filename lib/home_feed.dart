import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post.dart';
import 'user.dart';
import 'user_data.dart';
import 'camera_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'friend_service.dart';
import 'notification_screen.dart';

class MyFeed extends StatefulWidget {
  const MyFeed({super.key, required this.title});
  final String title;

  @override
  State<MyFeed> createState() => _MyFeedTest();
}

class _MyFeedTest extends State<MyFeed> {
  final UserData userData = UserData(FirebaseFirestore.instance);
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
    fetchAllPostData();
  }

  void _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    print('isFirstTime: $isFirstTime');
    if (isFirstTime) {
      _showWelcomeDialog();
      prefs.setBool('isFirstTime', false);
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white, // Customize the background color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'Live4youLine.png',
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Welcome to Live4You!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Live4You is not just another social media app; it's a platform designed to inspire you to live an active and fulfilling life. Each week, we present you with four exciting words/activities. Your mission: turn these words into actions! 🚴‍♂️🏞️\n\nHere's how it works:\n1. Every Monday, discover four new words of the week.\n2. Embark on exciting activities that align with the weekly words. \n3. Capture the moments by sharing photos of your completed activites.\n4. Personalize your profile, connect with friends, and share your journey through your post.\n\nLet Live4You be your guide to a more vibrant and active lifestyle! 🌟",
                  style: TextStyle(fontSize: 16, fontFamily: 'DNSans'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Explore'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void fetchAllPostData() async {
    // Fetch friends list
    await userData.populateFriendsList();
    List<String>? friendList = UserData.friends;

    // Add the current user's username to the list
    friendList?.add(UserData.userName);

    // Access Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // Fetch all posts
    QuerySnapshot querySnapshot = await firestoreInstance
        .collection('posts')
        .where('username', whereIn: friendList)
        .get();

    // Convert each document to a Post object and add it to the posts list
    List<Post> allPostData = querySnapshot.docs
        .map((doc) => Post.fromFirestore(doc, doc.id))
        .toList();

    // Sort posts by timestamp
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
        builder: (context) => MySearch(
          title: 'Search',
        ),
      ),
    );
  }

  void _navigateToMyUserProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyUserProfilePage(
          title: 'User Profile',
          // Add any necessary parameters for the profile screen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkIfFirstTime();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(251, 0, 0, 0),
        leading: IconButton(
        icon: Icon(Icons.notifications, color: Colors.white), // Bell icon
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsScreen(),
            ),
          );
        },
      ),
        flexibleSpace: Padding(
          padding: EdgeInsets.only(
              top: 60.0), // Adjust the top padding value to lower the image
          child: Center(
            child: Image.asset(
              'lib/assets/Live4youWhite.png', // Replace 'lib/assets/Live4youWhite.png' with your image path
              height: 120, // Adjust the height of the image
              width: 130, // Adjust the width of the image
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _navigateToMySearch,
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: _navigateToMyUserProfilePage,
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(248, 0, 0, 0),
      body: posts.isEmpty
          ? Center(
              child: Text("No posts..."),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return PostCard(post: posts[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
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
            fetchAllPostData(); // Refresh the feed if a new post was created
          }
        },
        tooltip: 'Camera',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FriendService friendService = FriendService();

  bool isLiked = false; // Track whether the post is liked
  bool isProcessing =
      false; // Track whether a like/unlike operation is in progress

  String timeAgo(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    //checking which post is made by the user
    isLiked = widget.post.likes?.contains(UserData.userName) ?? false;

    bool isPoster = widget.post.username == UserData.userName;
    double screenWidth = MediaQuery.of(context).size.width;
    double cutOffValue = 0.95;
    return Container(
      color: Color.fromARGB(248, 0, 0, 0),
      child: Column(
        children: [
          ListTile(
            leading: StreamBuilder<String?>(
              stream:
                  friendService.userProfilePictureStream(widget.post.username),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
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
                  if (profilePictureUrl == null || profilePictureUrl.isEmpty) {
                    // Use a default profile picture when there's no profile picture
                    imageProvider = const AssetImage(
                        'lib/assets/images/default_profile_picture.png');
                  } else {
                    // Use NetworkImage when loading an image from a URL
                    imageProvider = NetworkImage(profilePictureUrl);
                  }
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyUserProfilePage(
                          profileUserName: widget.post.username,
                          title: '',
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: imageProvider,
                  ),
                );
              },
            ),
            title: Text(
              widget.post.username,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 23,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              widget.post.caption,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            trailing: Container(
  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  child: Transform(
    transform: Matrix4.skewX(-0.05), // Adjust the skew factor as needed
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Adjust the padding values
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.post.word, // Placeholder for your word
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 22, // Adjust the font size as needed
          fontWeight: FontWeight.w900, // Adjust the fontWeight for thicker letters
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
          color: Colors.white,
        ),
      ),
    ),
  ),
)


          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.post.imageUrl,
              fit: BoxFit.fill,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_rounded,
                    color: isLiked ? Colors.teal : Colors.blueGrey),
                onPressed: () => likePost(context),
              ),
              Text(
                (widget.post.likeCount).toString(),
                style: TextStyle(
                    fontSize: 12,
                    color: isLiked ? Colors.teal : Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans'),
              ),
              Spacer(),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        timeAgo(widget.post.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
                      if (widget.post.username == UserData.userName)
                        IconButton(
                          icon: Icon(Icons.delete_forever),
                          color: Colors.blueGrey,
                          onPressed: () => deletePost(context),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
              height: 2.0,
              width: screenWidth * cutOffValue,
              color: Color.fromARGB(248, 35, 36, 44)),
        ],
      ),
    );
  }

  Future<void> deletePost(BuildContext parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (conext) {
          return SimpleDialog(
            title: Text("Delete post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () async {
                  //removes post from Firebase and user postList
                  Navigator.pop(conext);
                  await removeFromPostList();
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.getPostID())
                      .delete();
                  if (mounted) {
                    setState(() {});
                  }

                  ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
                    content: Text('Post has been deleted'),
                  ));
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              )
            ],
          );
        });
  }

  Future<void> removeFromPostList() async {
    final firestoreInstance = FirebaseFirestore.instance;
    await firestoreInstance.collection('users').doc(UserData.userName).update({
      'post_list': FieldValue.arrayRemove([widget.post.getPostID()])
    });
  }

  Future<void> likePost(BuildContext parentContext) async {
    if (isProcessing) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    final user = UserData.userName;
    widget.post.likes ??= [];

    //Use a transaction to handle concurrent updates safely
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(FirebaseFirestore
          .instance
          .collection('posts')
          .doc(widget.post.getPostID()));

      //Update likes, increment or decrement if necessary
      List<String> updatedLikes =
          List<String>.from(postSnapshot['likes'] ?? []);
      if (updatedLikes.contains(user)) {
        updatedLikes.remove(user);
      } else {
        updatedLikes.add(user);
      }

      // Update the document with the new data
      transaction.update(
          FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.post.getPostID()),
          {
            'likes': updatedLikes,
            'likecount': updatedLikes
                .length, // Update like count based on the length of the likes list
          });

      // Update the post object with the new data
      widget.post.likes = updatedLikes;
      widget.post.likeCount = updatedLikes
          .length; // Update like count based on the length of the likes list
    });

    // Set state to the change in likes
    setState(() {
      isLiked = widget.post.likes!.contains(user);
      isProcessing = false;
    });
  }
}
