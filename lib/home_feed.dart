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

  @override
  void initState() {
    super.initState();
    fetchAllPostData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(251, 0, 0, 0),
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
  bool isLiked = false; // Track whether the post is liked
  bool isProcessing =
      false; // Track whether a like/unlike operation is in progress

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
    isLiked = widget.post.likes?.contains(UserData.userName) ?? false;

    bool isPoster = widget.post.username == UserData.userName;
    double screenWidth = MediaQuery.of(context).size.width;
    double cutOffValue = 0.95;
    return Container(
      color: Color.fromARGB(248, 0, 0, 0),
      child: Column(
        children: [
          ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(widget.post.pfp),
              ),
              title: Text(widget.post.username,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.teal,
                ),
                child: Text(
                  'Word', //placeholder
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
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
                  fontFamily: 'DMSans'
                ),
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
      builder: (conext){
        return SimpleDialog(title: Text("Delete post?"),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async{
              //removes post from Firebase and user postList
              Navigator.pop(conext);
              await removeFromPostList();
              FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.post.getPostID())
              .delete();
              if(mounted){
                setState(() {
                  
                });
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
    await firestoreInstance
    .collection('users')
    .doc(UserData.userName)
    .update({'post_list' : FieldValue.arrayRemove([widget.post.getPostID()])
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
