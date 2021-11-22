import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedala_mi/models/user.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import "dart:math";

class TeamMembers extends StatefulWidget {
  TeamMembers({Key? key}) : super(key: key);

  @override
  _TeamMembersState createState() => _TeamMembersState();
}

class _TeamMembersState extends State<TeamMembers> {
  User? user = FirebaseAuth.instance.currentUser;
  bool check = false;
  final usernameController = TextEditingController();
  MiUser _miUser = new MiUser("", "", "", "");

  List<String> names = [
    "Panos", "Giancarlo", "Vincenzo", "Massimiliano", "David", "Emanuele", "Marcus", "Lorenzo", "Dimitra",
    "Michaelangelo", "Thaleia", "Raffaela", "Alessio", "Luke", "Jade", "Sarah", "Abrar", "Elsa", "Ferzeneh", "Gezim", "Gabriel", "Riccardo"
  ];

  List<String> teams = [
    "Polimi", "FER", "MDH", "TUDublin", "Random team", " \"For The Win\" team"
  ];

  final _random = new Random();

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
        //emailController.value =
        //   emailController.value.copyWith(text: _miUser.mail);
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

                      SizedBox(
                        width: 5 * SizeConfig.widthMultiplier!,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            nStringToNNString(user!.displayName),
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
                                    nStringToNNString(
                                        nStringToNNString(user!.email)),
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize:
                                      1.5 * SizeConfig.textMultiplier!,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 3 * SizeConfig.widthMultiplier!,
                              ),
                            ],
                          )
                        ],
                      )
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
                        Padding(
                          padding: EdgeInsets.only(
                              top: 3 * SizeConfig.heightMultiplier!),
                          child: Text(
                            // Team's Name Goes here
                            randomTeam(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 3.5 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline
                                ),
                             ),
                        ),

                        // Team Members
                        Padding(
                          padding: EdgeInsets.all(3),
                            child: Text(
                              randomName(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                            ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            randomName(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            randomName(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            randomName(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            randomName(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            randomName(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            randomName(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              top: 3 * SizeConfig.heightMultiplier!,
                              right: 10.0),
                        ),
                        SizedBox(
                          height: 30 * SizeConfig.heightMultiplier!,
                        ),
                        Container(
                          height: 20 * SizeConfig.heightMultiplier!,
                        ),
                        Divider(
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  String randomName()
  {
    var element = names[_random.nextInt(names.length)];
    return element;
  }

  String randomTeam()
  {
    var element = teams[_random.nextInt(teams.length)];
    return element;
  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }

}
