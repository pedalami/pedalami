import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pedala_mi/models/badge.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/routes/profile_editing.dart';
import 'package:pedala_mi/routes/sign_in_page.dart';
import 'package:pedala_mi/routes/single_ride_visualization.dart';
import 'package:pedala_mi/routes/teams_page.dart';
import 'package:pedala_mi/services/authentication.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/utils/mobile_library.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double trideduration = LoggedUser.instance!.statistics!.averageSpeed / 60;
  LoggedUser _miUser = LoggedUser.instance!;

  //Function that checks if time duration is less than a min returns in seconds
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

  Future<void> getRideHistory() async {
    _miUser.setRideHistory(
        await MongoDB.instance.getAllRidesFromUser(_miUser.userId));
  }

  @override
  void initState() {
    _miUser.addListener(() => setState(() {}));
    print("userId of the logged user is: " + _miUser.userId);
    //MongoDB.instance.initUser(_miUser.userId).then((value) => getRideHistory());
    getRideHistory();
    super.initState();
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
          child:
          _miUser.getNNBadges().isNotEmpty ?
          ListView(
            scrollDirection: Axis.horizontal,
            children: LoggedUser.instance?.badges
                    ?.map<Widget>((badge) => displayBadge(badge))
                    .toList() ??
                [Image.asset("badge_placeholder.png")],
          )
          :
          Center(
            child: Text(
              "Continue riding to earn badges.\nAll badges will be display here later",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )
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

  Widget header() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
            left: 30.0, right: 30.0, top: 10 * SizeConfig.heightMultiplier!, bottom: 2.5*SizeConfig.heightMultiplier!),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 11 * SizeConfig.heightMultiplier!,
                  width: 22 * SizeConfig.widthMultiplier!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      _miUser.image.url,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object object,
                          StackTrace? stacktrace) {
                        return Image.asset("lib/assets/app_icon.png");
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes as num)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 5 * SizeConfig.widthMultiplier!,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _miUser.username,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier!,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier!,
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              nStringToNNString(_miUser.mail),
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 1.5 * SizeConfig.textMultiplier!,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 7 * SizeConfig.widthMultiplier!,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 3 * SizeConfig.heightMultiplier!,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      LoggedUser.instance!.points!.round().toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier!,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Points",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 1.9 * SizeConfig.textMultiplier!,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      LoggedUser.instance!.redeemedRewards?.length.toString() ??
                          "0",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier!,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rewards",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 1.9 * SizeConfig.textMultiplier!,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        pushNewScreen(context,
                            screen: ProfileEditing(),
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                      child: Container(
                        /*width: 15 * SizeConfig.heightMultiplier!,*/
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "EDIT PROFILE",
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 1.8 * SizeConfig.textMultiplier!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier!,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Authentication.signOut(context: context);
                        setState(() {
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                                  _routeToSignInScreen(), (_) => false);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
                          child: Text(
                            "SIGN OUT",
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 1.8 * SizeConfig.textMultiplier!),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
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

  Widget stats() {
    return Column(
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
          padding: EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.grey.shade200.withOpacity(0.7),
              border: Border.all(
                color: Colors.black26.withOpacity(0.1),
              ),
            ),
            child: Transform.translate(
              offset: const Offset(-8,0),
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
                            timeDuration(
                                LoggedUser.instance!.statistics!.averageDuration),
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
                    height: 5//MediaQuery.of(context).size.height / 18,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget scrollArea() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // TODO: Read Ride data from MongoDB <----------------------------------------------------------
            stats(),
            // TODO: end of Statistics section <----------------------------------------------------
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
            SizedBox(
              height: 20 * SizeConfig.heightMultiplier!,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Column(
        children: <Widget>[
          header(),
          Container(
            child: Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        stats(),
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
                          height: 20 * SizeConfig.heightMultiplier!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget decideHistoryToShow() {
    //TODO: prob needs some refactoring
    Widget returnWidget;
    returnWidget = displayEmptyRideHistory();
    if (_miUser.rideHistory != null && _miUser.rideHistory!.isNotEmpty)
        returnWidget = displayRideHistory();
    return returnWidget;
  }

  Widget displayEmptyRideHistory() {
    return Container(
      child: Center(
          child: Text(
        "You have never recorded a ride.\nAll rides will be displayed here later",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      )),
    );
  }

  Widget displayRideHistory() {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black26.withOpacity(0.1),
            ),
            color: Colors.grey.shade200.withOpacity(0.7),
            borderRadius: BorderRadius.all(Radius.circular(18.0))),
        height: MediaQuery.of(context).size.height / 3,
        child: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black,
              );
            },
            itemCount: _miUser.rideHistory!.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  pushNewScreen(context,
                      screen: ShowSingleRideHistoryPage(
                          ride: _miUser.rideHistory![index]));
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / 11,
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEEE').format(DateTime.parse(
                                  _miUser.rideHistory![index].displayDate())),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              DateFormat('dd MMMM HH:mm').format(DateTime.parse(
                                  _miUser.rideHistory![index].displayDate())),
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Row(
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width) / 5.3,
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _miUser.rideHistory![index].points!
                                      .toStringAsFixed(0) +
                                  " Pts",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: FaIcon(FontAwesomeIcons.greaterThan),
                            flex: 1,
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              );
            }),
      ),
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

  String nStringToNNString(String? str) {
    return str ?? "";
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
