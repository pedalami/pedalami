import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pedala_mi/models/badge.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/ride_complete_page.dart';
import 'package:pedala_mi/services/web_authentication.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie_chart/pie_chart.dart';

class WebDashBoard extends StatefulWidget {
  final context;

  const WebDashBoard({Key? key, this.context}) : super(key: key);

  @override
  _WebDashBoardState createState() => _WebDashBoardState();
}

class _WebDashBoardState extends State<WebDashBoard> {
  LoggedUser? _miUser = LoggedUser.instance;


  Widget decideHistoryToShow() {
    //TODO: prob needs some refactoring
    Widget returnWidget;
    returnWidget = displayEmptyRideHistory();
    if (_miUser!.rideHistory != null && _miUser!.rideHistory!.isNotEmpty)
      returnWidget = displayRideHistory();
    return returnWidget;
  }

  Widget showStats() {
    return _miUser == null
        ? Container(
            height: MediaQuery.of(context).size.height / 5,
            width: MediaQuery.of(context).size.width / 8,
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              backgroundColor: Colors.grey,
            ),
          )
        : Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )),
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            stats(),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 15,
                            ),
                            _miUser!.rideHistory == null
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.all(25),
                                    child: pieChart(),
                                  ),
                            //TODO HEJ
                          ],
                        ),
                        Divider(
                          color: Colors.black,
                        ),
                        showBadges(),
                        Divider(
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 3 * SizeConfig.heightMultiplier!,
                        ),
                        showHistory(),
                        SizedBox(
                          height: 4 * SizeConfig.heightMultiplier!,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }

  Widget pieChart() {
    Map<String, double> data = {};
    _miUser!.rideHistory?.forEach((element) {
      double value = 0;
      String monthOfTheYear = DateFormat('MMMM').format(DateTime.parse(element.displayDate()));
      double? oldValue = data[monthOfTheYear];
      if (oldValue == null) {
        value = 1;
      } else {
        value = oldValue + 1;
      }
      data[monthOfTheYear] = value;
    });

    final colorList = <Color>[
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.yellow,
      Colors.orange,
      Colors.orangeAccent,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pinkAccent,
      Colors.cyan,
      Colors.deepPurpleAccent,
    ];

    PieChart pie = PieChart(
      dataMap: data,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 4,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 50,
      centerText: "Rides per month",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        chartValueStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        showChartValueBackground: false,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 0,
      ),
    );

    return pie;
  }

  @override
  Widget build(BuildContext context) {
    return LoggedUser.instance != null ? Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 8,
        leadingWidth: MediaQuery.of(context).size.width / 8,
        leading: Transform.scale(
          scale: 3,
          child: Padding(
            padding: EdgeInsets.only(top: 5.0, left: 15),
            child: Image.asset(
              'lib/assets/pedala_logo.png',
              height: MediaQuery.of(context).size.height / 10,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width / 90,
              top: MediaQuery.of(context).size.height / 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _miUser != null
                        ? Text(
                            _miUser!.username,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 100),
                          )
                        : JumpingDotsProgressIndicator(
                            fontSize: MediaQuery.of(context).size.width / 100,
                            color: Colors.white,
                          ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 90,
                    ),
                    _miUser != null
                        ? Container(
                            height: MediaQuery.of(context).size.width / 50,
                            width: MediaQuery.of(context).size.width / 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _miUser!.image,
                                )),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.width / 50,
                            width: MediaQuery.of(context).size.width / 50,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              backgroundColor: Colors.transparent,
                            ),
                          )
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    await webSignOut(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 90),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Logout",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize:
                                  MediaQuery.of(context).size.width / 120),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 90,
                        ),
                        FaIcon(FontAwesomeIcons.signOutAlt,
                            color: Colors.green,
                            size: MediaQuery.of(context).size.width / 50)
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
        backgroundColor: Colors.green.shade200,
      ),
      body: Center(child: showStats()),
    ) : Container();
  }

  Widget displayEmptyRideHistory() {
    return Container(
      child: Center(
          child: Text(
        "Currently you have no ride history, all rides will be displayed here later",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      )),
    );
  }

  Widget displayRideHistory() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.8,
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      //TODO: Fix the height size to change if there is a small amount of ride history / Marcus
      height: MediaQuery.of(context).size.height / 3,
      child: ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(
              color: Colors.black,
            );
          },
          itemCount: _miUser!.rideHistory!.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                pushNewScreen(context,
                    screen: RideCompletePage(
                      finishedRide: _miUser!.rideHistory![index],
                      bonusPoints: '0',
                    ));
              },
              child: Container(
                height: MediaQuery.of(context).size.height / 11,
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEEE').format(DateTime.parse(
                                _miUser!.rideHistory![index].displayDate())),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            DateFormat('dd MMMM HH:mm').format(DateTime.parse(
                                _miUser!.rideHistory![index].displayDate())),
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width + 10) / 3.3,
                    ),
                    Text(
                      _miUser!.rideHistory![index].points!.toStringAsFixed(0) +
                          " Pts",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 35,
                    ),
                    FaIcon(FontAwesomeIcons.greaterThan)
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget displayBadge(Badge badge) {
    //If you want to be able to click on a badge for more information you can wrap all this in GestureDetector and a Hero widget to another page

    return Padding(
      padding: EdgeInsets.all(9),
      child: Container(
        height: 20.0 * SizeConfig.heightMultiplier!,
        width: 30.0 * SizeConfig.widthMultiplier!,
        child: Stack(
          children: [
            //Image.network(
            //  "https://thumbs.dreamstime.com/b/gold-badge-5392868.jpg",
            //),
            Image.memory(base64Decode(badge.image)),
            Positioned.fill(
                child: Align(
              /*child: Text(
                //TODO descriptions are very long, I won't show them at the moment
                //(in the future one may tap on the badge and the description popups)
                badge.description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),*/
              alignment: Alignment.bottomCenter,
            )),
          ],
        ),
      ),
    );
  }

  Widget stats() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3 * SizeConfig.heightMultiplier!),
            child: Text(
              "Statistics",
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 2.5 * SizeConfig.textMultiplier!),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: Colors.grey.shade200.withOpacity(0.7),
                border: Border.all(
                  color: Colors.black26.withOpacity(0.1),
                ),
              ),
              child: Transform.translate(
                offset: const Offset(-10, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: singleStat(
                              "Total Rides",
                              LoggedUser.instance!.statistics!.numberOfRides
                                  .toString(),
                              ''),
                        ),
                        Expanded(
                          child: singleStat(
                              "Total Distance",
                              LoggedUser.instance!.statistics!.totalKm
                                  .toStringAsFixed(2),
                              ' km'),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: singleStat(
                              "Total Ride Duration",
                              timeDuration(
                                  LoggedUser.instance!.statistics!.totalDuration),
                              ''),
                        ),
                        Expanded(
                          child: singleStat(
                            "Total Elevation Gain",
                            meterDistance(LoggedUser
                                .instance!.statistics!.totalElevationGain),
                            '',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: singleStat(
                              "Average Speed",
                              LoggedUser.instance!.statistics!.averageSpeed
                                  .toStringAsFixed(2),
                              " km/h"),
                        ),
                        Expanded(
                          child: singleStat(
                              "Average Distance",
                              LoggedUser.instance!.statistics!.averageKm
                                  .toStringAsFixed(2),
                              " km"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: singleStat(
                              "Average Duration",
                              timeDuration(LoggedUser
                                  .instance!.statistics!.averageDuration),
                              ''),
                        ),
                        Expanded(
                          child: singleStat(
                              "Average Elevation Gain",
                              meterDistance(LoggedUser
                                  .instance!.statistics!.averageElevationGain),
                              ''),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget singleStat(String name, String query, String unit) {
    TextStyle headLine = TextStyle(
        color: Colors.black, fontSize: 2 * SizeConfig.textMultiplier!);
    TextStyle sub = TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 2 * SizeConfig.textMultiplier!);

    return Padding(
      padding: EdgeInsets.only(top: 1 * SizeConfig.heightMultiplier!),
      child: Column(
        children: <Widget>[
          Text(
            name,
            style: headLine,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                query,
                style: sub,
              ),
              Text(
                unit,
                style: sub,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String timeDuration(value) {
    double timemin = value / 60;
    double timehour;

    String hours(value) {
      timehour = value / 3600;
      return timehour.floor().toString();
    }

    if (value > 3600) {
      timemin = ((value % 60) * 0.6).toDouble();
    }

    return value > 3600
        ? (hours(value).toString() +
            " hours " +
            timemin.round().toString() +
            " min")
        : value > 60
            ? timemin.round().toString() + " min"
            : value.toString() + " sec";
  }

  //Function that checks if distance is less than 1km returns in meters
  String meterDistance(value) {
    String meters = value.toString();
    String kilometers = (value / 1000).round().toString();
    return value > 1000 ? kilometers + " km" : meters + " meters";
  }

  Widget showBadges() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3 * SizeConfig.heightMultiplier!),
          child: Text(
            "Earned Badges",
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 2.5 * SizeConfig.textMultiplier!),
          ),
        ),
        SizedBox(
          height: 3 * SizeConfig.heightMultiplier!,
        ),
        Container(
          height: 20 * SizeConfig.heightMultiplier!,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: LoggedUser.instance?.badges
                    ?.map<Widget>((badge) => displayBadge(badge))
                    .toList() ??
                [Image.asset("badge_placeholder.png")],
          ),
        ),
      ],
    );
  }

  Widget showHistory() {
    return Column(
      children: [
        Center(
          child: Text(
            "Previous Rides",
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 2.5 * SizeConfig.textMultiplier!),
          ),
        ),
        SizedBox(height: 3 * SizeConfig.heightMultiplier!),
        decideHistoryToShow(),
      ],
    );
  }
}
