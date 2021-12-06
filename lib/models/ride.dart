class Ride {
  String userId;
  String name;
  String? rideId;
  double? durationInSeconds;
  double? totalKm;
  double? pace;
  String date;
  num? elevationGain;
  num? points;

  Ride(this.userId, this.name, this.durationInSeconds, this.totalKm, this.pace,
      this.date, this.elevationGain, this.points);

  factory Ride.fromJson(dynamic json) {
    return Ride(
        json['userId'] as String,
        json['name'] as String,
        json['durationInSeconds'] as double?,
        json['totalKm'] as double?,
        json['pace'] as double?,
        json['date'] as String,
        json['elevationGain'] as int?,
        json['points'] as int?);
  }

  @override
  String toString() {
    return 'Ride{ rideId: $rideId, userId: $userId, name: $name, durationInSeconds: $durationInSeconds, totalKm: $totalKm, pace: $pace, date: $date, elevationGain: $elevationGain, earnedPoints: $points}';
  }
}
