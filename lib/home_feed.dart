import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post.dart';
import 'user.dart';

class MyFeed extends StatefulWidget {
  const MyFeed({super.key, required this.title, required this.userID});
  final String title;
  final String userID;

  @override
  State<MyFeed> createState() => _MyFeedTest();
}

class _MyFeedTest extends State<MyFeed> {
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

  Future<List<Post>> getFollowingPosts(List<String> followingList) async {
    List<Post> followingPosts = [];

    for (String userID in followingList) {
      List<String> postList = await User.fetchPostList(userID);
      for (String postID in postList) {
        Post? post = await fetchPostData(postID);
        if (post != null) {
          followingPosts.add(post);
        }
      }
    }
    return followingPosts;
  }

  Future<void> fetchAllPostData() async {
    List<String> followingList = await User.fetchFollowingList(widget.userID);
    List<Post> allPostData = await getFollowingPosts(followingList);
    setState(() {
      posts = allPostData;
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchAllPostData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live4You Homefeed'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return PostCard(post: posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
              context); // Navigate back to the previous screen (the homepage)
        },
        tooltip: 'Back',
        child: const Icon(Icons.add),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 55, 190, 253),
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
              child: Image.asset(widget.post.embed),
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
                child: Text(widget.post.date),
              )
            ],
          )
        ],
      ),
    );
  }
}
