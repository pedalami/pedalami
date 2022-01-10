import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/routes/event_ranking.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/date_time_ext.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class EnrollItem extends StatefulWidget {
  const EnrollItem({Key? key, required Event event, required refresh, required Team actualTeam}) : refresh=refresh,event=event, actualTeam = actualTeam, super(key: key);
  final Function refresh;
  final Event event;
  final Team actualTeam;

  @override
  _EnrollItemState createState() => _EnrollItemState();
}

class _EnrollItemState extends State<EnrollItem> {
  late bool _enrolled;


  @override
  void initState() {
    _enrolled = hasEnrolled();
    super.initState();
  }

  bool hasEnrolled()
  {
    for(int i=0;i<widget.event.scoreboard!.length;i++)
    {
      if(widget.event.scoreboard![i].userId==FirebaseAuth.instance.currentUser!.uid)
      {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, right: 20,left: 20),
      child: Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 5),
              child: Text(widget.event.name,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: <Widget>[
                      widget.event.isIndividual()?widget.event.prize != null ? Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text("Points: "+widget.event.prize!.toStringAsFixed(0),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!
                          ),
                        ),
                      ):SizedBox():SizedBox(),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text("Event Type: "+(widget.event.isTeam()?"Team" : "Unknown Type"),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text("Event Visibility: "+(widget.event.isPublic()?"Public":widget.event.isPrivate()?"Private":""),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text("Started: "+widget.event.startDate.formatIT,
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text("Ends: "+widget.event.endDate.formatIT,
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                //!_joined?buildJoinButton():buildLeaveButton(context),
                ElevatedButton(
                    style: !_enrolled?ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.lightGreen)))):ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Colors.grey),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: Colors.grey)))),
                    child:
                    AnimatedCrossFade(
                        duration: Duration(milliseconds: 100),
                        crossFadeState: _enrolled
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild:
                        Text("Enroll"),
                        secondChild: Text('Enrolled'))
                    ,
                    onPressed: () async{
                      if(!_enrolled)
                      {
                        if(await MongoDB.instance.enrollTeamToPublicEvent(widget.event.id, widget.actualTeam.adminId, widget.actualTeam.id))
                        {
                          setState(() {
                            _enrolled = !_enrolled;
                          });
                          widget.refresh();
                        }
                        else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                              Text("You cannot enroll multiple active events simultaneously.")));
                        }
                      }
                    }
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}