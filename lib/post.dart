class Post {
  String caption;
  String date;
  int likeCount;
  final int _postid;
  var embed;
  var user;
  Post(this._postid, this.user, this.caption, this.embed, this.date,
      this.likeCount);
}

var samplePost = [
  Post(123, "John", "Took a hike!", "hiketrail.jpg", "10/02/2023", 4),
  Post(321, "Bob", "Went for a swim!", "pool.jpg", "10/03/2023", 43),
  Post(231, "Claire", "Had a nice walk!", "park.jpg", "10/04/2023", 343),
];
