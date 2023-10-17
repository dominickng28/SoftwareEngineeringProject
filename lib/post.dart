class Post {
  String caption;
  String date;
  String username;
  int likeCount;
  final int _postid;
  String embed;
  var userID;
  Post(this.username, this._postid, this.userID, this.caption, this.embed, this.date,
      this.likeCount);
}

var samplePost = [
  Post('John', 123, 222222222, "Took a hike!", "hiketrail.jpg", "10/02/2023", 4),
  Post('Bob', 321, 186918691, "Went for a swim!", "pool.jpg", "10/03/2023", 43),
  Post('Clair', 231, 186918691, "Had a nice walk!", "park.jpg", "10/04/2023", 343),
];
