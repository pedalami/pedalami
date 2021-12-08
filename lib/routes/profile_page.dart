import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/routes/profile_editing.dart';
import 'package:pedala_mi/routes/sign_in_page.dart';
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
  //User? user = FirebaseAuth.instance.currentUser;
  late LoggedUser _miUser;
  List<Ride>? rideHistory;

  void getRideHistory() async {
    rideHistory = await MongoDB.instance.getAllRidesFromUser(_miUser.userId);
    print(rideHistory);
    print("DONE");
  }

  @override
  void initState() {
    _miUser = LoggedUser.instance!;
    print(_miUser.userId);
    getRideHistory();

    /*
    OLD. See the above new declaration of _miUser LoggedUser for reference.
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection("Users");
    usersCollection
        .where("Mail", isEqualTo: user!.email)
        .get()
        .then((QuerySnapshot querySnapshot) async {

          //This setState serves no purpose, I leave it here if you want explanation why this is redundant /Marcus

      setState(() {
        _miUser = new LoggedUser(
            querySnapshot.docs[0].id,
            querySnapshot.docs[0].get("Image"),
            querySnapshot.docs[0].get("Mail"),
            querySnapshot.docs[0].get("Username"), 0.0);
      });
      //TODO - Comment added by Vincenzo:
      //This should not be there for sure. Every time the app is opened points are retrieved from MongoDB.
      //My suggestion is to have a single shared MiUser to use in the whole application.
    });
     */
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
                          "500",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 3 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Total KM",
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
                          "28",
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
                            left: 30.0, top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Your Statistics",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Total Distance: 95km",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Average Speed: 15km/h",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Total Ride Duration: 30min",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Average Distance: 45km",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Average Elevation Gain: 20",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Average Duration/Ride: 15min",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      // TODO: end of Statistics section <----------------------------------------------------
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Badges",
                          style: TextStyle(
                              color: Colors.black,
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
                          children: [
                            displayBadge(1),
                            displayBadge(1),
                            displayBadge(1),
                            displayBadge(1),
                            displayBadge(1),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 3 * SizeConfig.heightMultiplier!,
                      ),
                      rideHistory == null
                          ? displayEmptyRideHistory()
                          : displayRideHistory(),
                      SizedBox(
                        height: 3 * SizeConfig.heightMultiplier!,
                      ),
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
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
      child: ListView.builder(
          itemCount: rideHistory!.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: MediaQuery.of(context).size.height / 17,
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(rideHistory![index].displayDate()),

                  //TODO: Here I will add a button to take the user to another page and show the entire route on map
                ],
              ),
            );
          }),
    );
  }

  Widget displayBadge(badgeID) {
    //If you want to be able to click on a badge for more information you can wrap all this in GestureDetector and a Hero widget to another page

    return Padding(
      padding: EdgeInsets.all(9),
      child: Container(
        height: 20.0 * SizeConfig.heightMultiplier!,
        width: 30.0 * SizeConfig.widthMultiplier!,
        child: Stack(
          children: [
            Image.network(
              "https://thumbs.dreamstime.com/b/gold-badge-5392868.jpg",
            ),
            Positioned.fill(
                child: Align(
              child: Text(
                "Badge info here",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
