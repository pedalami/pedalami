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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.green[600],
              height: 30 * SizeConfig.heightMultiplier!,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                    widget.team.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 4 * SizeConfig.textMultiplier!,),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0,-30),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )
                ),
                // Team Members
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Members",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 2.5 * SizeConfig.textMultiplier!,),),
                    ),
                    ListView.builder(
                        itemCount: widget.team.membersId.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5 * SizeConfig.widthMultiplier!),
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
                  ],
                ),
              ),
            ),
          ],
        ),
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
