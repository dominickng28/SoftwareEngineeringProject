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

class _MyFeedTest extends State<MyFeed>{
  List<Post> posts = [];

Future<Post?> fetchPostData(String postId) async {
  try {
    // Accessing Firestore instance
    final firestoreInstance = FirebaseFirestore.instance;

    // Get the post document
    final postDocument = await firestoreInstance.collection('post').doc(postId).get();

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
    Widget build(BuildContext context){
      fetchAllPostData();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Live4You Homefeed'),
        ),
        body: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index){
           return PostCard(post: posts[index]); 
          },
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Navigate back to the previous screen (the homepage)
        },
        tooltip: 'Back',
        child: const Icon(Icons.add),
      ),
      );
    }
}
class PostCard extends StatelessWidget{
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context){
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(post.username),
            subtitle: Text(post.caption),
          ),
          Image.network(post.embed),
          Row(
            children: [
              const Icon(Icons.thumbs_up_down),
              Text(post.likeCount.toString())
            ],
          )
        ],
      )
    );
  }
}
