import 'package:pedala_mi/models/statistics.dart';
import 'package:pedala_mi/models/badge.dart';

class MongoUser {
  String userId;
  String? username;
  double points;
  Statistics? statistics;
  List<Badge>? badges;


  MongoUser(this.userId, this.username, this.points, this.statistics, this.badges);

  factory MongoUser.fromJson(dynamic json) {
    return MongoUser(
        json['userId'] as String,
        null,
        double.parse(json['points'].toString()),
        Statistics.fromJson(json['statistics']),
        null
        //Badge.fromJson(json['badges'])
    );
  }

  @override
  String toString() {
    return 'MongoUser{userId: $userId, username: $username, points: $points, statistics: $statistics}';
  }
}
