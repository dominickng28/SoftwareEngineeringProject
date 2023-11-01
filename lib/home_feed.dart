import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'post.dart';

class MyFeed extends StatefulWidget {
  const MyFeed({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyFeed> createState() => _MyFeed();
}

class _MyFeed extends State<MyFeed> {
  int _currentIndex = 0;

  final List<Post> posts = [
    Post('Kenny', 'SampleImages/pfp1.jpg', '123', '222222222', "Caught a lot of fish!",
        "SampleImages/fish.jpg", "10/15/2023", 4),
    Post('Bob', 'SampleImages/pfp2.jpeg', '321', '186918691', "Went for a swim!", "SampleImages/pool.jpg",
        "10/03/2023", 43),
    Post('Clair', 'SampleImages/pfp3.jpg', '231', '186918691', "Had a nice walk!", "SampleImages/park.jpg",
        "10/04/2023", 343),
  ];

  void onTabSwapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live4You Homefeed'),
      ),
      backgroundColor: Color.fromARGB(255, 163, 221, 248),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return PostCard(post: posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          },
         child: Icon(Icons.add),
         backgroundColor: Colors.white,
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
        side: BorderSide(color: Color.fromARGB(255, 2, 23, 117), width: 6.0), // Set the border color and width here
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
                imageHeight = isExpanded ? 400.0 : 200.0; // Set your desired expanded and small sizes here
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
                icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt, color: isLiked ? Color.fromARGB(255, 2, 23, 117) : null),
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
              Padding(padding: EdgeInsets.only(right: 16.0),
              child: Text(widget.post.date),)
            ],
          )
        ],
      ),
    );
  }
}