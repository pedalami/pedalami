import 'package:pedala_mi/models/ride.dart';

class Ride {
  String uid;
  String name;
  String? rideId;
  double? durationInSeconds;
  double? totalKm;
  double? pace;
  String date;
  double? elevation_gain;
  num? points;

  Ride(this.uid, this.name, this.durationInSeconds, this.totalKm, this.pace,
      this.date, this.elevation_gain, this.points);

  factory Ride.fromJson(dynamic json) {
    return Ride(json['uid'] as String,
        json['name'] as String,
        json['durationInSeconds'] as double?,
        json['totalKm'] as double?,
        json['pace'] as double?,
        json['date'] as String,
        json['elevation_gain'] as double?,
        json['points'] as int?);
  }

  @override
  String toString() {
    return 'Ride{ rideId: $rideId, uid: $uid, name: $name, durationInSeconds: $durationInSeconds, totalKm: $totalKm, pace: $pace, date: $date, elevation_gain: $elevation_gain, earnedPoints: $points}';
  }
}
