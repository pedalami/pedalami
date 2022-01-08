import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/routes/create_team.dart';
import 'package:pedala_mi/routes/teams_page.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/teams_search_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/routes/team_members.dart';

class TeamsSearchPage extends StatefulWidget {
  TeamsSearchPage({Key? key}) : super(key: key);
  @override
  _TeamsSearchPageState createState() => _TeamsSearchPageState();
}

class _TeamsSearchPageState extends State<TeamsSearchPage> {
  LoggedUser? user;
  List<Team>? foundTeams;
  late bool hasSearched, loading;
  final teamSearchController = TextEditingController();

  @override
  void initState() {
    user = LoggedUser.instance!;
    user!.addListener(() {setState((){});});
    hasSearched = false;
    loading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.green[600],
                height: 20 * SizeConfig.heightMultiplier!,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 30.0,
                      right: 30.0,
                      top: 3 * SizeConfig.heightMultiplier!),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 5 * SizeConfig.heightMultiplier!),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20.0,
                                  //top: 1 * SizeConfig.heightMultiplier!,
                                  right: 20),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    counterStyle: TextStyle(
                                      color: CustomColors.silver,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide:
                                          BorderSide(color: CustomColors.green),
                                    ),
                                    hintText: "Search for team",
                                    hintStyle:
                                        TextStyle(color: CustomColors.silver)),
                                controller: teamSearchController,
                                onSubmitted: (value) async {
                                  setState(() {
                                    hasSearched = true;
                                    loading = true;
                                  });
                                  foundTeams = await MongoDB.instance
                                      .searchTeam(teamSearchController.text);
                                  setState(() {
                                    loading = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              !hasSearched
                  ? Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 7.0 * SizeConfig.widthMultiplier!,
                                ),
                                //)
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : loading
                      ? Text("Loading...")
                      : (foundTeams != null && foundTeams!.length > 0
                          ? Column(
                            children: [
                              TeamSearchButton(teamsFound: foundTeams!),
                              Divider(
                                color: Colors.grey[500],
                              ),
                            ],
                          )
                          : Text("No teams found")),

              //TODO: better ui loading or no results
              Padding(
                padding: EdgeInsets.only(
                  left: 40.0,
                  top: 1 * SizeConfig.heightMultiplier!,
                  right: 30.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(alignment: Alignment.center),
                    Text(
                      "My Teams",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 3 * SizeConfig.textMultiplier!),
                    ),
                    SizedBox(
                      width: 15 * SizeConfig.heightMultiplier!,
                    ),
                    Align(alignment: Alignment.centerRight),
                    FloatingActionButton.extended(
                      backgroundColor: Colors.lightGreen,
                      label: FaIcon(FontAwesomeIcons.plus, color: Colors.white,),
                      onPressed: () {
                        pushNewScreen(
                          context,
                          screen: TeamCreation(),
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
              ),
              displayTeam(),
              SizedBox(height: MediaQuery.of(context).size.height*.02,)
            ],
          ),
        ),
      ),
    );
  }

  Widget displayTeam() {
    return ListView.builder(
        itemCount: LoggedUser.instance!.teams?.length ?? 0,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Stack(
              children: [
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       ClipRRect(
                       borderRadius: BorderRadius.circular(70),
                       child: Image(
                        image: AssetImage('lib/assets/app_icon.png'),
                        height: 16 * SizeConfig.heightMultiplier!,
                        width: 32 * SizeConfig.widthMultiplier!,
                      ),
                    ),],
                  ),
                  onTap: () async {
                    Team selectedTeam = LoggedUser.instance!.teams![index];
                    if (selectedTeam.members == null) {
                      print("Getting team data");
                      selectedTeam = (await MongoDB.instance.getTeam(selectedTeam.id))!;
                      LoggedUser.instance!.teams![index] = selectedTeam;
                    }
                    print("Showing team details");
                    pushNewScreen(
                      context,
                      screen: TeamProfile(team: selectedTeam),
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                ),
                Positioned.fill(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          LoggedUser.instance!.teams![index].name,
                          style: TextStyle(
                              fontSize: 2 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        )))
              ],
            ),
            onTap: () {
              pushNewScreen(
                context,
                screen: TeamProfile(
                  team: LoggedUser.instance!.teams![index],
                ),
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
          );
        });
  }
}
