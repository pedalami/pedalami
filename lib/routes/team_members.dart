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
          /*
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
                            nStringToNNString("REMOVE"),
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
          */
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
                            widget.team.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 4 * SizeConfig.textMultiplier!,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        // Team Members
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: ListView.builder(
                              itemCount: widget.team.membersId.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 1 * SizeConfig.heightMultiplier!),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Member username",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              2 * SizeConfig.textMultiplier!,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            1 * SizeConfig.heightMultiplier!,
                                      ),
                                      Text(
                                        getUsername(index),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              2 * SizeConfig.textMultiplier!,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            2 * SizeConfig.heightMultiplier!,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
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

  String nStringToNNString(String? str) {
    return str ?? "";
  }

  String getUsername(int index) {
    return widget.team.members!.values.elementAt(index).username ??
        "Error while getting username";
  }
}
