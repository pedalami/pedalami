
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/teams_search_button.dart';



class TeamsSearchPage extends StatefulWidget {
  TeamsSearchPage({Key? key}) : super(key: key);
  @override
  _TeamsSearchPageState createState() => _TeamsSearchPageState();
}

class _TeamsSearchPageState extends State<TeamsSearchPage> {
  User? user;
  List<Team>? foundTeams;
  late bool hasSearched;
  final teamSearchController = TextEditingController();

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    hasSearched=false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              color: Colors.green[600],
              height: 45 * SizeConfig.heightMultiplier!,
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
                                style: TextStyle(color: Colors.white),
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
                                controller: teamSearchController,
                                onSubmitted: (value)async{
                                  hasSearched=true;
                                  foundTeams=await MongoDB.instance.searchTeam(teamSearchController.text);
                                  setState(() {

                                  });


                                },
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
            !hasSearched?
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 30.0,
                          right: 30.0,),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(alignment: Alignment.center),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/create_team");
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
                                Navigator.pushNamed(context, "/current_team");  //TODO: If user has no active team, show dialog window with message to join the team
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
                  ],
                ),
              ),
            ):(foundTeams!.length==0?Text("No teams found"):TeamSearchButton(teamsFound: foundTeams!)),
          ],
        ),
    );
  }


}

