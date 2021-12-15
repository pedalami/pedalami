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
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);


  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double trideduration = LoggedUser.instance!.statistics!.averageSpeed / 60;
  LoggedUser _miUser = LoggedUser.instance! ;

  //Function that checks if time duration is less than a min returns in seconds
  String timeDuration(value) {
    String norm = value.toString();
    String timedur = (value / 60).round().toString();
    return value > 60 ? timedur + " min" : norm + " sec";
  }

  //Function that checks if distance is less than 1km returns in meters
  String meterDistance(value) {
    String norm = value.toString();
    String mdistance = (value / 1000).round().toString();
    return value > 1000 ? mdistance + " km" : norm + " meters";
  }

  Future<void> getRideHistory() async {
    _miUser.setRideHistory(await MongoDB.instance.getAllRidesFromUser(_miUser.userId));
  }

  @override
  void initState() {
    _miUser.addListener(() => setState(() {}));
    print("userId of the logged user is: "+_miUser.userId);
    //MongoDB.instance.initUser(_miUser.userId).then((value) => getRideHistory());
    getRideHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          color: Colors.green[600],
          height: 40 * SizeConfig.heightMultiplier!,
          child: Padding(
            padding: EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                top: 10 * SizeConfig.heightMultiplier!),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        height: 11 * SizeConfig.heightMultiplier!,
                        width: 22 * SizeConfig.widthMultiplier!,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _miUser.image,
                            )),
                      ),
                      onTap: () async {
                        await Authentication.signOut(context: context);
                        Navigator.of(context).pushAndRemoveUntil(
                            _routeToSignInScreen(),
                                (Route<dynamic> route) => false);
                      },
                    ),
                    SizedBox(
                      width: 5 * SizeConfig.widthMultiplier!,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          nStringToNNString(_miUser.username),
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
                          LoggedUser.instance!.redeemedRewards?.length.toString() ?? "0",
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
                    GestureDetector(
                      onTap: () {
                        pushNewScreen(context,
                            screen: ProfileEditing(),
                            pageTransitionAnimation:
                            PageTransitionAnimation.cupertino);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "EDIT PROFILE",
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 1.8 * SizeConfig.textMultiplier!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 35 * SizeConfig.heightMultiplier!),
            child: Container(
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
                      // TODO: Read Ride data from MongoDB <----------------------------------------------------------
                      Padding(
                        padding: EdgeInsets.only(
                            top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Statistics",
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 2 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Total Rides: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Text(
                              LoggedUser.instance!.statistics!.numberOfRides.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Total Distance: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  LoggedUser.instance!.statistics!.totalKm.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                                Text(
                                  " km",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Total Ride Duration: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  timeDuration(LoggedUser.instance!.statistics!.totalDuration),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Total Elevation Gain: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  meterDistance(LoggedUser.instance!.statistics!.totalElevationGain),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Average Speed: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  LoggedUser.instance!.statistics!.averageSpeed.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                                Text(
                                  " km/h",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Average Distance: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  LoggedUser.instance!.statistics!.averageKm.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                                Text(
                                  " km",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Average Duration per Ride: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  timeDuration(LoggedUser.instance!.statistics!.averageDuration),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget> [
                            Text(
                              "Average Elevation Gain: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(
                                  meterDistance(LoggedUser.instance!.statistics!.averageElevationGain),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // TODO: end of Statistics section <----------------------------------------------------
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 3 * SizeConfig.heightMultiplier!),
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
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 3 * SizeConfig.heightMultiplier!,
                      ),
                      Center(
                        child: Text(
                          "Previous Rides",
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      SizedBox(height: 3*SizeConfig.heightMultiplier!),
                      decideHistoryToShow(),
                      SizedBox(
                        height: 20 * SizeConfig.heightMultiplier!,
                      ),
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget decideHistoryToShow() {
    //TODO: prob needs some refactoring
    Widget returnWidget;
    _miUser.rideHistory == null
        ? returnWidget = displayEmptyRideHistory()
        : returnWidget = displayRideHistory();
    return returnWidget;
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
          itemCount: _miUser.rideHistory!.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                pushNewScreen(context,
                    screen: ShowSingleRideHistoryPage(
                        path: _miUser.rideHistory![index].path!));
              },
              child: Container(
                height: MediaQuery.of(context).size.height / 11,
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
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
                    SizedBox(
                      width: (MediaQuery.of(context).size.width + 10) / 3.3,
                    ),
                    Text(
                      _miUser.rideHistory![index].points!.toStringAsFixed(0) + " Pts",
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
