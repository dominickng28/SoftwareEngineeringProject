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

  /* UNUSED/OUTDATED CODE
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
 */

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
    if(mounted){
    setState(() {
      posts = allPostData;
    });
  }
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
    backgroundColor: const Color.fromARGB(249, 253, 208, 149),
      body: posts.isEmpty ? Center( 
        child: Text("No posts..."),):
      ListView.builder(
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
  
  //Check to properly initialize the isLiked variable
  @override
  void initState(){
    super.initState();
    isLiked = widget.post.likes?.contains(UserData.userName) ?? false;
  }

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
    //checking which post is made by the user
    bool isPoster = widget.post.username == UserData.userName;
    double screenWidth = MediaQuery.of(context).size.width;
    double cutOffValue = 0.95;
    return Container(
      color: const Color.fromARGB(249, 253, 208, 149),
      child: Column(
        children: [ 
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(widget.post.pfp),
            ),
            title: Text(widget.post.username),
            subtitle: Text(widget.post.caption),
            trailing: isPoster
            ? IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => deletePost(context),
            ): null
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(widget.post.imageUrl, fit: BoxFit.cover,
            ),
          ),         
          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt,
                    color: isLiked ? Color.fromARGB(255, 2, 23, 117) : null),
                onPressed: () => likePost(context),
              ),
              Text((widget.post.likeCount).toString()),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(timeAgo(widget.post.date)),
              ),
            ],
          ),
          Container(
            height: 2.0,
            width: screenWidth * cutOffValue,
            color: Color.fromARGB(248, 172, 113, 36)
          ),
        ],
      ),
    );
  }

  Future<void> deletePost(BuildContext parentContext) async{
    return showDialog(
      context: parentContext,
      builder: (conext){
        return SimpleDialog(title: Text("Delete post?"),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async{
              //removes post from Firebase and user postList
              Navigator.pop(conext);
              await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.post.getPostID())
              .delete();
              await removeFromPostList();

              ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
              content: Text('Post has been deleted'),
              ));
            },
            child: Text('Delete',
            style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          )
        ],
        );
      }
    );
  }

  Future<void> removeFromPostList() async{
    final firestoreInstance = FirebaseFirestore.instance;
    await firestoreInstance
    .collection('users')
    .doc(UserData.userName)
    .update({'postList' : FieldValue.arrayRemove([widget.post.getPostID()])
    });
  }

  Future<void> likePost(BuildContext parentContext) async {
    final user = UserData.userName;
    widget.post.likes ??= [];

    //Use a transaction to handle concurrent updates safely
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot =
        await transaction.get(FirebaseFirestore.instance.collection('posts').doc(widget.post.getPostID()));

      //Update likes, increment or decrement if necessary
      List<String> updatedLikes = List<String>.from(postSnapshot['likes'] ?? []);
      if (updatedLikes.contains(user)) {
        updatedLikes.remove(user);
        widget.post.likeCount--; 
      } else {
        updatedLikes.add(user);
        widget.post.likeCount++; 
      }

      // Update the document with the new data
      transaction.update(FirebaseFirestore.instance.collection('posts').doc(widget.post.getPostID()), {
        'likes': updatedLikes,
        'likeCount': widget.post.likeCount,
      });
    });

    // Set state to the change in likes
    setState(() {
      isLiked = widget.post.likes!.contains(user);
    });
  }
}