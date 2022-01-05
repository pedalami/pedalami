import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/team.dart';

class TeamMembers extends StatefulWidget {
  TeamMembers({Key? key, required this.team}) : super(key: key);
  final Team team;

  @override
  _TeamMembersState createState() => _TeamMembersState();
}

class _TeamMembersState extends State<TeamMembers> {
  bool check = false;
  final usernameController = TextEditingController();

  @override
  void initState() {
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
              top: 15.0 * SizeConfig.heightMultiplier!),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget> [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                          // Team's Name Goes here
                          widget.team.name,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 4 * SizeConfig.textMultiplier!,
                              decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 25 * SizeConfig.heightMultiplier!),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )
                ),
                // Team Members
                child: Container(
                  height: MediaQuery.of(context).size.height/2,
                  child: ListView.builder(
                      itemCount: widget.team.membersId.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!,
                              left: 10 * SizeConfig.widthMultiplier!),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                (index+1).toString()+": "+getUsername(index),
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      2.5 * SizeConfig.textMultiplier!,
                                ),
                              ),
                              SizedBox(
                                height: 2 * SizeConfig.heightMultiplier!,
                              ),
                            ],
                          ),
                        );
                      }),
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

  String getUsername(int index) {
    return widget.team.members!.values.elementAt(index).username ??
        "Error while getting username";
  }
}
