class Statistics {
  int numberOfRides;
  int totalDuration;
  int totalKm;
  int totalElevationGain;
  int averageSpeed;
  int averageDuration;
  int averageKm;
  int averageElevationGain;


  Statistics(
      this.numberOfRides,
      this.totalDuration,
      this.totalKm,
      this.totalElevationGain,
      this.averageSpeed,
      this.averageDuration,
      this.averageKm,
      this.averageElevationGain);

  factory Statistics.fromJson(dynamic json) {
    return Statistics(
        json['numberOfRides'] as int,
        json['totalDuration'] as int,
        json['totalKm'] as int,
        json['totalElevationGain'] as int,
        json['averageSpeed'] as int,
        json['averageDuration'] as int,
        json['averageKm'] as int,
        json['averageElevationGain'] as int);
  }

  @override
  String toString() {
    return 'Statistics {\n'
        ' numberOfRides: $numberOfRides,\n'
        ' totalDuration: $totalDuration,\n'
        ' totalKm: $totalKm,\n'
        ' totalElevationGain: $totalElevationGain,\n'
        ' averageSpeed: $averageSpeed,\n'
        ' averageDuration: $averageDuration,\n'
        ' averageKm: $averageKm,\n'
        ' averageElevationGain: $averageElevationGain\n}\n';
  }
}
