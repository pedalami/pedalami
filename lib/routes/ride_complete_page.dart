import 'package:flutter/material.dart';
import 'package:pedala_mi/models/ride.dart';

class RideCompletePage extends StatelessWidget {
  final Ride finishedRide;
  final String bonusPoints;

  const RideCompletePage(
      {Key? key, required this.finishedRide, required this.bonusPoints})
      : super(key: key);

  Widget singleStat(String name, String unit, BuildContext context) {
    TextStyle headLine = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
    TextStyle sub = TextStyle(fontSize: 20);

    return Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width / 12,
          bottom: MediaQuery.of(context).size.height / 35),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: headLine,
            ),
          ),
          Expanded(
            child: Text(
              unit,
              style: sub,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Results",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                decoration: TextDecoration.underline),
          )),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          singleStat(
              'Time: ',
              (finishedRide.durationInSeconds! / 60).toStringAsFixed(1) +
                  " min",
              context),
          singleStat('Distance: ',
              finishedRide.totalKm!.toStringAsFixed(2) + " km", context),
          singleStat('Pace: ', finishedRide.pace!.toStringAsFixed(2) + " km/h",
              context),
          singleStat('Elevation gain: ',
              finishedRide.elevationGain!.toStringAsFixed(2) + " m", context),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          Container(
            height: 150,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
                color: Colors.green[200],
                borderRadius: BorderRadius.all(Radius.circular(18.0))),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Points Earned",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  finishedRide.points!.toStringAsFixed(0),
                  style: TextStyle(
                      fontSize: 60,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .2),
            child: bonusPoints != "0"
                ? Text(
                    "You obtained " +
                        bonusPoints +
                        " bonus points for riding in adverse weather!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  )
                : SizedBox(),
          )
        ],
      )),
    );
  }
}
