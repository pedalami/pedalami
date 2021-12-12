import 'dart:io';
//import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/events_page.dart';
import 'package:pedala_mi/routes/team_members.dart';
import 'package:pedala_mi/routes/teams_search.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/routes/teams_search.dart';

class TeamProfile extends StatefulWidget {
  TeamProfile({Key? key}) : super(key: key);

  @override
  _TeamProfileState createState() => _TeamProfileState();
}

class _TeamProfileState extends State<TeamProfile> {
  bool check = false;
  LoggedUser _miUser = LoggedUser.instance!;
  Team? active;

  String teamName = /*active!.name;*/ "Team Awesome";
  String description = /*active!.description.toString(); */ "Nerd guys with high ambitions";
  String teamAdmin = /*active!.adminId;*/ "Admin's username";


  void initValues() async{
    active = await MongoDB.instance.getTeam("61af228ca2719ca673109a22");
    //active = await MongoDB.instance.getTeam("yTi9ZmJbK4Sy4yykwRvrDAcCFPB3");
    //print(active!.name);
  }

  String adminsUsername(){
    if(_miUser.userId == LoggedUser.instance!.teams!.first.adminId)
      return _miUser.username;
    else
      return "Admin's uername";
  }

  @override
  void initState() {
    //initValues();

    /*
    OLD. See the above new declaration of _miUser LoggedUser for reference.
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection("Users");
    usersCollection
        .where("Mail", isEqualTo: user!.email)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      setState(() {
        _miUser = new LoggedUser(
            querySnapshot.docs[0].id,
            querySnapshot.docs[0].get("Image"),
            querySnapshot.docs[0].get("Mail"),
            querySnapshot.docs[0].get("Username"), 0.0);
        usernameController.value =
            usernameController.value.copyWith(text: _miUser.username);
        //TODO - Comment added by Vincenzo:
        //This should not be there for sure. Every time the app is opened points are retrieved from MongoDB.
        //My suggestion is to have a single shared MiUser to use in the whole application.
      });
    });
     */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //initValues();
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            color: Colors.green[600],
            height: 45 * SizeConfig.heightMultiplier!,
            width: 100 * SizeConfig.widthMultiplier!,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 10 * SizeConfig.heightMultiplier!),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        height: 22 * SizeConfig.heightMultiplier!,
                        width: 32 * SizeConfig.widthMultiplier!,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightGreen,
                          /*image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      nStringToNNString(_miUser.image)),*/
                        ),
                      ),
                      Text(
                        _miUser.teams!.first.name.toString(),
                        //LoggedUser.instance!.teams!.first.name.toString(),
                        // teamName, //active!.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 4 * SizeConfig.textMultiplier!,),
                      ),

                      SizedBox(
                        width: 5 * SizeConfig.widthMultiplier!,
                      ),
                      /*Divider(
                        color: Colors.black54,
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding (
            padding: EdgeInsets.only(top: 10 * SizeConfig.heightMultiplier!),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[]
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40 * SizeConfig.heightMultiplier!),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  )),
              child: Container(
                //child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 30.0, top: 4 * SizeConfig.heightMultiplier!, right: 30.0,),
                  child: Column(
                    children: <Widget> [
                      Text( "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 2.5 * SizeConfig.textMultiplier!,),
                      ),
                      Text( _miUser.teams!.first.description.toString(),
                        //LoggedUser.instance!.teams!.first.description.toString(),
                        //description, //active!.description.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                          fontSize: 2 * SizeConfig.textMultiplier!,),
                      ),
                      Divider(
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 3 * SizeConfig.heightMultiplier!),),
                      Text( "Team Admin",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 2.5 * SizeConfig.textMultiplier!,),
                      ),
                      Text(//teamAdmin, // active!.adminId,
                         adminsUsername(),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                          fontSize: 2.3 * SizeConfig.textMultiplier!,),
                      ),
                      /*Padding(
                                  padding: EdgeInsets.only(
                                    top: 5 * SizeConfig.heightMultiplier!),),
                                 ElevatedButton(
                                  onPressed: () {
                                    pushNewScreen(
                                      context,
                                      screen: EventsPage(),
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Text("Events", textAlign: TextAlign.center,),
                                  style: ButtonStyle(
                                      fixedSize: MaterialStateProperty.all(
                                          Size(200, 35)),
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.lightGreen),
                                          shape: MaterialStateProperty.all(
                                               RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(18.0),
                                                   side: BorderSide(
                                              color: Colors.lightGreen)))),
                                  ),*/
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10.0,
                            top: 3 * SizeConfig.heightMultiplier!,
                            right: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen: TeamMembers(),
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,

                            );
                          },
                          child: Text("Team Members"),
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                  Size(200, 35)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightGreen),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.lightGreen)))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10.0,
                            top: 3 * SizeConfig.heightMultiplier!,
                            right: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen: TeamsSearchPage(),
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,

                            );
                          },
                          child: Text("Leave team", style: TextStyle(color: Colors.grey[800]),),
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                  Size(200, 35)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.redAccent),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.redAccent)))),
                        ),
                      ),
                      SizedBox(
                        height: 3 * SizeConfig.heightMultiplier!,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }

/*void checkValue() async {
    setState(() {
      check = true;
    });
    await updateUsername(usernameController.text, context, _miUser);
    setState(() {
      check = false;
    });
  }*/

}