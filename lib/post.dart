class Post{

  String caption;
  String date;
  int like_count;
  final int _postid;
  var embed;
  Post(this._postid, this.caption, this.date, this.like_count, this.embed)
}