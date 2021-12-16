class Statistics {
  int numberOfRides;
  int totalDuration;
  int totalKm;
  int totalElevationGain;
  int averageSpeed;
  int averageDuration;
  double averageKm;
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

      double.parse(json['numberOfRides'].toString()).round(),
      double.parse(json['totalDuration'].toString()).round(),
      double.parse(json['totalKm'].toString()).round(),
      double.parse(json['totalElevationGain'].toString()).round(),
      double.parse(json['averageSpeed'].toString()).round(),
      double.parse(json['averageDuration'].toString()).round(),
      double.parse(json['averageKm'].toString()),
      double.parse(json['averageElevationGain'].toString()).round()
    );
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
