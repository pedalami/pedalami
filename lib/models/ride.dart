import 'package:flutter_osm_interface/flutter_osm_interface.dart';
import 'package:intl/intl.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class Ride {
  String userId;
  String name;
  String? rideId;
  double? durationInSeconds;
  double? totalKm;
  double? pace;
  DateTime date;
  double? elevationGain;
  double? points;
  List<GeoPoint>? path;

  Ride(this.userId, this.name, this.rideId, this.durationInSeconds, this.totalKm, this.pace,
      this.date, this.elevationGain, this.points, this.path);

  factory Ride.fromJson(dynamic json) {
    List<GeoPoint> pathList = (json['path'] as List)
        .map<GeoPoint>((e) => new GeoPoint(
            latitude: double.parse(e['latitude'].toString()),
            longitude: double.parse(e['longitude'].toString()))
        ).toList();
    return Ride(
      json['userId'] as String,
      json['name'] as String,
      json['_id'] as String,
      double.parse(json['durationInSeconds'].toString()),
      double.parse(json['totalKm'].toString()),
      double.parse(json['pace'].toString()),
      MongoDB.parseDate(json['date'] as String), //parse server date format
      double.parse(json['elevationGain'].toString()),
      double.parse(json['points'].toString()),
      pathList
    );
  }

  String displayDate() {
    return DateFormat("yyyy-MM-dd HH:mm").format(date.toLocal());
  }

  @override
  String toString() {
    return 'Ride{ rideId: $rideId, userId: $userId, name: $name, durationInSeconds: $durationInSeconds, totalKm: $totalKm, pace: $pace, date: '+displayDate()+', elevationGain: $elevationGain, earnedPoints: $points}';
  }
}
