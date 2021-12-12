import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/routes/teams_search.dart';
import "dart:math";

class TeamMembers extends StatefulWidget {
  TeamMembers({Key? key}) : super(key: key);

  @override
  _TeamMembersState createState() => _TeamMembersState();
}

class _TeamMembersState extends State<TeamMembers> {
  //User? user = FirebaseAuth.instance.currentUser;
  bool check = false;
  final usernameController = TextEditingController();
  LoggedUser _miUser = LoggedUser.instance!;
  Team? active;
  String? activateTeams;
  String nullz = "Caught null string";
  late List<String> tmz;

  //boolean function that checks if the user exists to that team
  bool checkUserInTeam(List<String>? users) {
    if (users == null)
      return false;
    String myId = FirebaseAuth.instance.currentUser!.uid;
    for (int i=0; i < users.length; i++) {
      if (users[i] == myId)
        return true;
    }
    return false;
  }

  //Async function that going through teams to check if the user belongs to that team
  void teamMem() async {
    /*for(int i = 0; i < teamsFound.length; i++)
    {
      if(checkUserInTeam(teamsFound[i].membersId.cast<String>()))
      {
        active = await MongoDB.instance.getTeam(teamsFound[i].id);
      }
    }*/
    //active = await MongoDB.instance.getTeam(teamId);
    active = await MongoDB.instance.getTeam("61af228ca2719ca673109a22");
  }

  // Temporary check for null strings when receiving data from MongoDB
  String checkNull() {
    activateTeams = _miUser.teams!.first.name.toString();

    return _miUser.teams!.first.name.toString();
  }

  List<String> teamMemberz()
  {
    for(int i = 0; i < LoggedUser.instance!.teams!.length; i++)
    {
      tmz.add(LoggedUser.instance!.teams![i].name.toString());
    }
    return tmz;
  }

  // TODO : Make Dynamic read from users enrolled to team
  List<String> names = [
    "Panos", "Giancarlo", "Vincenzo", "Massimiliano", "David", "Emanuele", "Marcus", "Lorenzo", "Dimitra",
    "Michaelangelo", "Thaleia", "Raffaela", "Alessio", "Luke", "Jade", "Sarah", "Abrar", "Elsa", "Ferzeneh", "Gezim", "Gabriel", "Riccardo"
  ];

  // TODO : Make Dynamic read from teams joined to
  List<String> teams = [
    "Polimi", "FER", "MDH", "TUDublin", "Random team", " \"For The Win\" team"
  ];

  final _random = new Random();

  @override
  void initState() {
    teamMem();

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
        //emailController.value =
        //   emailController.value.copyWith(text: _miUser.mail);
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
                            nStringToNNString(_miUser.username),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 3 * SizeConfig.textMultiplier!,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 1 * SizeConfig.heightMultiplier!,
                          ),
                          Container(
                            height: 11 * SizeConfig.heightMultiplier!,
                            width: 22 * SizeConfig.widthMultiplier!,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _miUser.image,
                                )),
                          ),
                          Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    nStringToNNString(
                                        nStringToNNString(_miUser.mail)),
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
                              top: 3 * SizeConfig.heightMultiplier!,
                              bottom: 3 * SizeConfig.heightMultiplier!),
                          child: Text(
                            // Team's Name Goes here
                            checkNull(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 4 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline
                            ),
                          ),
                        ),
                        // Team Members
                        displaymemberz(),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              top: 2 * SizeConfig.heightMultiplier!,
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

  Widget displaymemberz() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
        child: ListView.builder(
          itemCount: LoggedUser.instance!.teams!.first.membersId.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: EdgeInsets.only(
                top: 1 * SizeConfig.heightMultiplier!),
              child: Column(
              children: <Widget>[
                Text("Member ID",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 2 * SizeConfig.textMultiplier!,
                    ),
                  ),
                SizedBox(
                  height: 1 * SizeConfig.heightMultiplier!,
                ),
              Text(LoggedUser.instance!.teams!.first.membersId[index].toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 2 * SizeConfig.textMultiplier!,
                ),
              ),
                SizedBox(
                  height: 2 * SizeConfig.heightMultiplier!,
                ),
             ],
              ),
            );
          }),
    );
  }

/*Widget displayNamet() {
    return Padding(
      padding: EdgeInsets.all(9),
      child: ElevatedButton(
        onPressed: () async {
            active = await MongoDB.instance.getTeam("61af228ca2719ca673109a22");
            setState(() {
            });
          },
        child: Text(checkNull()),
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
      );
  }*/

}