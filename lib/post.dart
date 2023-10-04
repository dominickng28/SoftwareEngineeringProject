class Post{

  String caption;
  String date;
  int like_count;
  final int _postid;
  var embed;
  var user;
  Post(this._postid, this.user, this.caption, this.embed, this.date, this.like_count);
}
var sample_post = [
  Post(123, "Sporticas454", "Took a hike!", "hiketrail.jpg", "10/02/2023", 4),
  Post(321, "Freddie", "Went for a swim!", "pool.jpg", "10/03/2023", 43),
  Post(231, "Alex", "Had a nice walk!", "park.jpg", "10/04/2023", 343),
];