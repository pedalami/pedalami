import 'package:pedala_mi/models/statistics.dart';
import 'package:pedala_mi/models/badge.dart';

class MongoUser {
  String userId;
  double points;
  Statistics? statistics;
  List<Badge>? badges;


  MongoUser(this.userId, this.points, this.statistics, this.badges);

  factory MongoUser.fromJson(dynamic json) {
    return MongoUser(
        json['userId'] as String,
        double.parse(json['points'].toString()),
        Statistics.fromJson(json['statistics']),
        null
        //Badge.fromJson(json['badges'])
    );
  }

  @override
  String toString() {
    return 'MongoUser{userId: $userId, points: $points, statistics: $statistics}';
  }
}
