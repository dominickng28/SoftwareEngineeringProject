import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post.dart';
import 'user.dart';
import 'user_data.dart';
import 'camera_screen.dart';

class MyFeed extends StatefulWidget {
  const MyFeed({super.key, required this.title});
  final String title;

  @override
  State<MyFeed> createState() => _MyFeedTest();
}

class _MyFeedTest extends State<MyFeed> {
  final UserData userData = UserData(FirebaseFirestore.instance);
  List<Post> posts = [];

  Future<Post?> fetchPostData(String postId) async {
    try {
      // Accessing Firestore instance
      final firestoreInstance = FirebaseFirestore.instance;

      // Get the post document
      final postDocument =
          await firestoreInstance.collection('post').doc(postId).get();

      if (postDocument.exists) {
        // Create a Post instance from Firestore data
        Post post = Post.fromFirestore(postDocument, postId);
        return post;
      } else {
        // Handle the case where the document doesn't exist (return a default or error value)
        return null;
      }
    } catch (e) {
      // Handle any errors, e.g., log the error
      print('Error fetching post data: $e');
      return null;
    }
  }

  Future<List<Post>> getFriendsPosts(List<String> friendsList) async {
    List<Post> friendsPosts = [];

    for (String userID in friendsList) {
      List<String> postList = await User.fetchPostList(userID);
      for (String postID in postList) {
        Post? post = await fetchPostData(postID);
        if (post != null) {
          friendsPosts.add(post);
        }
      }
    }
    return friendsPosts;
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

    setState(() {
      posts = allPostData;
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchAllPostData();
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromRGBO(0, 45, 107, 0.992),
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: 60.0), // Adjust the top padding value to lower the image
        child: Center(
          child: Image.asset(
            'lib/assets/Live4youWhite.png', // Replace 'lib/assets/Live4youWhite.png' with your image path
            height: 120, // Adjust the height of the image
            width: 130, // Adjust the width of the image
          ),
        ),
      ),
    ),

      body: ListView.builder(
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
  bool isLiked = false; // Track whether the post is liked
  bool isExpanded = false; // Track whether the post embed is expanded
  double imageHeight = 200.0; // Initial height
  String timeAgo(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} day(s) ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour(s) ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(249, 253, 208, 149),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Color.fromARGB(255, 2, 23, 117),
            width: 6.0), // Set the border color and width here
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(widget.post.pfp),
            ),
            title: Text(widget.post.username),
            subtitle: Text(widget.post.caption),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                imageHeight = isExpanded
                    ? 400.0
                    : 200.0; // Set your desired expanded and small sizes here
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300), // Animation duration
              height: imageHeight,
              child: Image.network(widget.post.imageUrl),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt,
                    color: isLiked ? Color.fromARGB(255, 2, 23, 117) : null),
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                    if (isLiked) {
                      widget.post.likeCount++;
                    } else {
                      widget.post.likeCount--;
                    }
                  });
                },
              ),
              Text(widget.post.likeCount.toString()),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(timeAgo(widget.post.date)),
              )
            ],
          )
        ],
      ),
    );
  }
}
