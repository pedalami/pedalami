import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/event_ranking.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/date_time_ext.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class TeamEventItem extends StatefulWidget {
  const TeamEventItem({Key? key, required Event event, required refresh}) : refresh=refresh,event=event,super(key: key);
  final Function refresh;
  final Event event;

  @override
  _TeamEventItemState createState() => _TeamEventItemState();
}

class _TeamEventItemState extends State<TeamEventItem> {

  late Event event;
  //late bool _joined;


  @override
  void initState() {
    event=widget.event;
    //_joined=hasJoined();
    super.initState();
  }

  /*bool hasJoined()
  {
    for(int i=0;i<event.scoreboard!.length;i++)
    {
      if(event.scoreboard![i].userId==FirebaseAuth.instance.currentUser!.uid)
      {
        return true;
      }
    }
    return false;
  }*/

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, right: 20,left: 20),
      child: GestureDetector(
        onTap: (){
          pushNewScreen(context, screen: EventRankingPage(event: event,));
        },
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
                child: Text(event.name,
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
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("Event Type: "+(event.isPublic()?"Public":event.isPrivate()?"Private":""),
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
                          child: Text("Started: "+event.startDate.formatIT,
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
                          child: Text("Ends: "+event.endDate.formatIT,
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
                  /*ElevatedButton(
                      style: !_joined?ButtonStyle(
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
                          crossFadeState: _joined
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild:
                          Text(""),
                          secondChild: Text("")),
                      onPressed: () async{

                      }
                  )*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
