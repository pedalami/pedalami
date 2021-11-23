import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/user.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';

class TeamProfile extends StatefulWidget {
  TeamProfile({Key? key}) : super(key: key);

  @override
  _TeamProfileState createState() => _TeamProfileState();
}

class _TeamProfileState extends State<TeamProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  bool check = false;
  final usernameController = TextEditingController();
  MiUser _miUser = new MiUser("", "", "", "");
  File? f;

  @override
  void initState() {
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection("Users");
    usersCollection
        .where("Mail", isEqualTo: user!.email)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      setState(() {
        _miUser = new MiUser(
            querySnapshot.docs[0].id,
            querySnapshot.docs[0].get("Image"),
            querySnapshot.docs[0].get("Mail"),
            querySnapshot.docs[0].get("Username"));
        usernameController.value =
            usernameController.value.copyWith(text: _miUser.username);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            color: Colors.green[600],
            height: 45 * SizeConfig.heightMultiplier!,
            width: 100 * SizeConfig.heightMultiplier!,
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
                      Text( "Team Awesome",
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
                children: <Widget>[
                  ]
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
                          padding: EdgeInsets.only(top: 5 * SizeConfig.heightMultiplier!),
                          child: Column(
                            children: <Widget>[
                              Text( "Description",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 2.5 * SizeConfig.textMultiplier!,),
                              ),
                              Text( "Nerd guys with high ambitions",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                  fontSize: 2 * SizeConfig.textMultiplier!,),
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
                                Text( "Admin's username",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                  fontSize: 2.3 * SizeConfig.textMultiplier!,),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 7 * SizeConfig.heightMultiplier!),),
                                 ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/events");
                                  },
                                  child: Text("Team Events"),
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Colors.lightGreen),
                                          shape: MaterialStateProperty.all(
                                               RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(18.0),
                                                   side: BorderSide(
                                              color: Colors.lightGreen)))),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10.0,
                                      top: 3 * SizeConfig.heightMultiplier!,
                                      right: 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, "/team_members");
                                        },
                                        child: Text("Team Members"),
                                        style: ButtonStyle(
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
                                        onPressed: () {},
                                        child: Text("Leave current team", style: TextStyle(color: Colors.grey[800]),),
                                        style: ButtonStyle(
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
            )))],
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
