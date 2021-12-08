class MongoUser {
  String userId;
  String username;
  double points;


  MongoUser(this.userId, this.username, this.points);

  factory MongoUser.fromJson(dynamic json) {
    return MongoUser(json['userId'] as String, json['username'] as String, double.parse(json['points'].toString()));
  }
}
