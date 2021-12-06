import 'package:flutter_osm_interface/flutter_osm_interface.dart';

class Ride {
  String userId;
  String name;
  String? rideId;
  double? durationInSeconds;
  double? totalKm;
  double? pace;
  String date;
  double? elevationGain;
  double? points;
  List<GeoPoint>? path;

  Ride(this.userId, this.name, this.durationInSeconds, this.totalKm, this.pace,
      this.date, this.elevationGain, this.points, this.path);

  factory Ride.fromJson(dynamic json) {
    List<GeoPoint> pathList = json['path'].map((e) => new GeoPoint(latitude: e.latitude, longitude: e.longitude)).toList();
    return Ride(
      json['userId'] as String,
      json['name'] as String,
      json['durationInSeconds'] as double?,
      json['totalKm'] as double?,
      json['pace'] as double?,
      json['date'] as String,
      json['elevationGain'] as double?,
      json['points'] as double?,
      pathList
    );
  }



  @override
  String toString() {
    return 'Ride{ rideId: $rideId, userId: $userId, name: $name, durationInSeconds: $durationInSeconds, totalKm: $totalKm, pace: $pace, date: $date, elevationGain: $elevationGain, earnedPoints: $points}';
  }
}
