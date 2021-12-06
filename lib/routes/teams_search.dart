
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/routes/create_team.dart';
import 'package:pedala_mi/routes/teams_page.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/teams_search_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




class TeamsSearchPage extends StatefulWidget {
  TeamsSearchPage({Key? key}) : super(key: key);
  @override
  _TeamsSearchPageState createState() => _TeamsSearchPageState();
}

class _TeamsSearchPageState extends State<TeamsSearchPage> {
  User? user;
  List<Team>? foundTeams;
  late bool hasSearched, loading;
  final teamSearchController = TextEditingController();

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    hasSearched=false;
    loading=false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
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
                                    loading=true;
                                    setState(() {

                                    });
                                    foundTeams=await MongoDB.instance.searchTeam(teamSearchController.text);
                                    loading=false;
                                    setState(() {

                                    });
                                  },
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
                                    pushNewScreen(
                                      context,
                                      screen: TeamCreation(),
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,

                                    );
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
                                  pushNewScreen(
                                    context,
                                    screen: TeamProfile(),
                                    pageTransitionAnimation: PageTransitionAnimation.cupertino,

                                  );  //TODO: If user has no active team, show dialog window with message to join the team
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
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "My Teams",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    "https://novaanime.org/wp-content/uploads/2021/08/one-punch-man-filler-list.jpeg",
                                    height: 20.0 * SizeConfig.heightMultiplier!,
                                    width: 50.0 * SizeConfig.widthMultiplier!,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        "Team Awesome",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )))
                            ],
                          ),
                          SizedBox(
                            width: 7.0 * SizeConfig.widthMultiplier!,
                          ),
                          Container(
                            width: 32.0 * SizeConfig.widthMultiplier!,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                pushNewScreen(
                                  context,
                                  screen: TeamProfile(),
                                  pageTransitionAnimation: PageTransitionAnimation
                                      .cupertino,

                                );
                              },
                              label: Text("Info"),
                              icon: FaIcon(FontAwesomeIcons.userCog),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.green[400]),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.green)))),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ):loading?Text("Loading..."):(foundTeams!.length==0?Text("No teams found"):TeamSearchButton(teamsFound: foundTeams!)),
              //TODO: better ui loading or no results
            ],
          ),
        ),
    );
  }


}

