import 'package:flutter/material.dart';
import 'post.dart';
class MyFeed extends StatefulWidget {
  const MyFeed({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyFeed> createState() => _MyFeed();
}

class _MyFeed extends State<MyFeed>{
    final List<Post> posts = [
      Post('Kenny', 123, 222222222, "Caught a lot of fish!", "SampleImages/fish.jpg", "10/15/2023", 4),
      Post('Bob', 321, 186918691, "Went for a swim!", "SampleImages/pool.jpg", "10/03/2023", 43),
      Post('Clair', 231, 186918691, "Had a nice walk!", "SampleImages/park.jpg", "10/04/2023", 343),
    ];

    @override
    Widget build(BuildContext context){
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
        child: const Icon(Icons.arrow_back),
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
          Image.asset(post.embed),
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