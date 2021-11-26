import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pedala_mi/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/services/mongodb_service.dart';


class TeamCreation extends StatefulWidget {
  TeamCreation({Key? key}) : super(key: key);

  @override
  _TeamCreationState createState() => _TeamCreationState();
}

class _TeamCreationState extends State<TeamCreation> {
  User? user = FirebaseAuth.instance.currentUser;
  bool check = false;
  final usernameController = TextEditingController();
  MiUser _miUser = new MiUser("", "", "", "");

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
                //color: Colors.green[600],
                //height: 45 * SizeConfig.heightMultiplier!,
                //width: 100 * SizeConfig.widthMultiplier!,
                child: Padding(
                    padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 10 * SizeConfig.heightMultiplier!),
                    child: Column(
                    children: <Widget>[

                    ],
                    ),
                ),
            ),
            ],
        )
    );
  }
}
