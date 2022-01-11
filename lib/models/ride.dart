import 'package:intl/intl.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class GeoPoint {
  final double longitude;
  final double latitude;

  GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  GeoPoint.fromMap(Map m)
      : this.latitude = m["lat"],
        this.longitude = m["lon"];

  Map<String, double> toMap() {
    return {
      "lon": longitude,
      "lat": latitude,
    };
  }

  @override
  String toString() {
    return 'GeoPoint{latitude: $latitude , longitude: $longitude}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          runtimeType == other.runtimeType &&
          longitude == other.longitude &&
          latitude == other.latitude;

  @override
  int get hashCode => longitude.hashCode ^ latitude.hashCode;
}

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

  Ride(
      this.userId,
      this.name,
      this.rideId,
      this.durationInSeconds,
      this.totalKm,
      this.pace,
      this.date,
      this.elevationGain,
      this.points,
      this.path);

  factory Ride.fromJson(dynamic json) {
    List<GeoPoint> pathList = (json['path'] as List<dynamic>)
        .map<GeoPoint>((e) => new GeoPoint(
            latitude: double.parse(e['latitude'].toString()),
            longitude: double.parse(e['longitude'].toString())))
        .toList();
    return Ride(
        json['userId'] as String,
        json['name'] as String,
        json['_id'] as String,
        double.parse(json['durationInSeconds'].toString()),
        double.parse(json['totalKm'].toString()),
        double.parse(json['pace'].toString()),
        MongoDB.parseDate(json['date'] as String),
        //parse server date format
        double.parse(json['elevationGain'].toString()),
        double.parse(json['points'].toString()),
        pathList);
  }

  String displayDate() {
    return DateFormat("yyyy-MM-dd HH:mm").format(date.toLocal());
  }

  @override
  String toString() {
    return 'Ride{ rideId: $rideId, userId: $userId, name: $name, durationInSeconds: $durationInSeconds, totalKm: $totalKm, pace: $pace, date: ' +
        displayDate() +
        ', elevationGain: $elevationGain, earnedPoints: $points}';
  }
}
