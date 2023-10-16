class Post {
  String caption;
  String date;
  int likeCount;
  final int _postid;
  var embed;
  var userID;
  Post(this._postid, this.userID, this.caption, this.embed, this.date,
      this.likeCount);
}

var samplePost = [
  Post(123, 222222222, "Took a hike!", "hiketrail.jpg", "10/02/2023", 4),
  Post(321, 186918691, "Went for a swim!", "pool.jpg", "10/03/2023", 43),
  Post(231, 186918691, "Had a nice walk!", "park.jpg", "10/04/2023", 343),
];
