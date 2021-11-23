
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';



class TeamsSearchPage extends StatefulWidget {
  TeamsSearchPage({Key? key}) : super(key: key);
  @override
  _TeamsSearchPageState createState() => _TeamsSearchPageState();
}

class _TeamsSearchPageState extends State<TeamsSearchPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              color: Colors.green[600],
              height: 45 * SizeConfig.heightMultiplier!,
              //width: 5 * SizeConfig.widthMultiplier!,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 10 * SizeConfig.heightMultiplier!),
                child: Column(
                  children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 5 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20.0,
                                  top: 10 * SizeConfig.heightMultiplier!,
                                  right: 20),
                              child: TextField(
                                cursorColor: CustomColors.green,
                                decoration: InputDecoration(
                                    counterStyle: TextStyle(
                                      color: CustomColors.silver,
                                    ),
                                    enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0),
                                      borderSide:
                                      BorderSide(color: CustomColors.silver),
                                    ),
                                    focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0),
                                      borderSide:
                                      BorderSide(color: CustomColors.green),
                                    ),
                                    hintText: "Search for team",
                                    hintStyle:
                                    TextStyle(color: CustomColors.silver)),
                                //controller: usernameController,
                                //maxLength: 20,
                                //style: TextStyle(color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 3 * SizeConfig.heightMultiplier!,
                            ),
                          ],
                          ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 50 * SizeConfig.heightMultiplier!),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(alignment: Alignment.center),
                      ElevatedButton(
                          onPressed: () {
                            },
                          child: Text("Create New Team"),
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                  Size(200, 35)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightGreen),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0)))),
                       ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/current_team");
                        },
                        child: Text("Your Current Team"),
                        style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all(
                                Size(200, 35)),
                            backgroundColor: MaterialStateProperty.all(
                                Colors.lightGreen),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)))),
                      ),
                    ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

