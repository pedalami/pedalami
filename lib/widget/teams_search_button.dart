import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class TeamSearchButton extends StatefulWidget {
  const TeamSearchButton({Key? key, required List<Team> teamsFound,}) : teamsFound=teamsFound,super(key: key);
  final List<Team>teamsFound;

  @override
  _TeamSearchButtonState createState() => _TeamSearchButtonState();
}

class _TeamSearchButtonState extends State<TeamSearchButton> {
  late List<Team> teamsFound;

  @override
  void initState() {
    teamsFound=widget.teamsFound;


    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: teamsFound.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return Container(
            height: MediaQuery.of(context).size.height * .2,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
              EdgeInsets.all(MediaQuery.of(context).size.width * (.02)),
              child: Material(
                child: InkWell(
                  onTap: () {
                    //TODO: retrieve data from mongoDB and open a new page
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset("lib/assets/app_logo.png"),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment(0, -1),
                            end: Alignment(0, 0.5),
                            colors: [
                              const Color(0xCC000000).withOpacity(0.1),
                              const Color(0x00000000),
                              const Color(0x00000000),
                              const Color(0xCC000000).withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      teamsFound[i].name,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                              .size
                                              .width *
                                              (.05),
                                          color: Colors.white),
                                    ))),
                          ),
                          !checkUserInTeam(teamsFound[i].membersId.cast<String>() )?Padding(padding: const EdgeInsets.all(12),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child:
                              //TODO: check if user is already enrolled to this specific team. If so do not show the button but nothing (SizedBox())
                              ElevatedButton(
                                onPressed: () async{
                                  if(await MongoDB.instance.joinTeam(teamsFound[i].id, FirebaseAuth.instance.currentUser!.uid))
                                    {
                                      if(LoggedUser.instance!.teams == null) {
                                        LoggedUser.instance!.teams =
                                            List.empty(growable: true);
                                      }
                                      LoggedUser.instance!.teams!.add(teamsFound[i]);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          "Joined "+teamsFound[i].name+" successfully!",),
                                      ));
                                      teamsFound[i].membersId.cast<String>().add(FirebaseAuth.instance.currentUser!.uid);
                                      teamsFound.remove(teamsFound[i]);
                                      LoggedUser.instance!.notifyListeners();
                                      setState(() {});
                                    }
                                  else
                                    {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          "Something wrong happened... Please try again.",),
                                      ));
                                    }
                          },
                            child: Text("Join"),
                            style: ButtonStyle(

                                backgroundColor: MaterialStateProperty.all(
                                    Colors.lightGreen),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0)))),
                          ),
                              
                            ),
                          ),):SizedBox()
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }


}
