import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/routes/event_ranking.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/date_time_ext.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:search_choices/search_choices.dart';

class EventItem extends StatefulWidget {
  const EventItem({Key? key, required Event event, required refresh}) : refresh=refresh,event=event,super(key: key);
  final Function refresh;
  final Event event;

  @override
  _EventItemState createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {

  late Event event;
  late bool _joined, joining;
  late List<Team?> joinableTeams=[];
  bool loadingJoinableTeams=true;
  var selectedValueSingleDoneButtonDialog;
  List<DropdownMenuItem>? item;
  Team? selectedTeam;
  late DateTime localStartDate, localEndDate;


  @override
  void initState() {

    joining=false;
    event=widget.event;
    _joined=hasJoined();
    localStartDate=DateFormat("yyyy-MM-dd HH:mm:ss").parse(event.startDate.toString(),true).toLocal();
    localEndDate=DateFormat("yyyy-MM-dd HH:mm:ss").parse(event.endDate.toString(),true).toLocal();
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if(event.isTeam()) {
        if(!_joined)
          {
            for(String enrolledTeamId in event.enrolledTeamsIds!)
            {
              for(int i=0;i<LoggedUser.instance!.teams!.length;i++)
              {
                if(LoggedUser.instance!.teams![i].id==enrolledTeamId)
                {
                  joinableTeams.add(await MongoDB.instance.getTeam(enrolledTeamId));
                }
              }
            }
            item=joinableTeams.map<DropdownMenuItem>((item) => DropdownMenuItem(
              value: item,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(item!.name),
              ),
            )).toList();
          }
        else
          {
            for(ScoreboardEntry s in event.scoreboard!)
              {
                if(s.userId==FirebaseAuth.instance.currentUser!.uid)
                  {
                    selectedTeam=await MongoDB.instance.getTeam(s.teamId!);
                  }
              }
          }
        loadingJoinableTeams=false;
        setState(() {});
      }

    });
  }

  bool hasJoined()
  {
    for(int i=0;i<event.scoreboard!.length;i++)
      {
        if(event.scoreboard![i].userId==FirebaseAuth.instance.currentUser!.uid)
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
                        event.isIndividual()?event.prize!=null?Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("Points: "+event.prize!.toStringAsFixed(0),
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
                          child: Text("Event Type: "+(event.isTeam()?"Team":event.isIndividual()?"Individual":""),
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
                          child: Text("Event Visibility: "+(event.isPublic()?"Public":event.isPrivate()?"Private":""),
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
                          child: Text("Started: "+localStartDate.formatIT,
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
                          child: Text("Ends: "+localEndDate.formatIT,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        event.isTeam()?
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Row(
                            children: [
                              Text("Team: ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                              !loadingJoinableTeams?!_joined?SearchChoices.single(
                                items: item,
                                value: selectedValueSingleDoneButtonDialog,
                                hint: "Select one team",
                                searchHint: "Select one team",
                                onChanged: (value) {
                                  setState(() {
                                    selectedTeam=(value as Team);
                                    selectedValueSingleDoneButtonDialog = value;
                                  });
                                },
                                doneButton: "Done",
                                displayItem: (item, selected) {
                                  return (Row(children: [
                                    selected
                                        ? Icon(
                                      Icons.radio_button_checked,
                                      color: Colors.grey,
                                    )
                                        : Icon(
                                      Icons.radio_button_unchecked,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 7),
                                    Expanded(
                                      child: item,
                                    ),
                                  ]));
                                },
                              ):Text(selectedTeam!.name,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ):Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: SizedBox(
                                  height: 2 * SizeConfig.heightMultiplier!,
                                  width: 2 * SizeConfig.heightMultiplier!,
                                  child: CircularProgressIndicator(
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ):SizedBox()
                      ],
                    ),
                  ),
                  ElevatedButton(
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
                          Text("Join"),
                          secondChild: Text('Joined')),
                      onPressed: () async{
                        if(!_joined)
                        {
                          if(!joining)
                          {
                            try
                            {
                              joining=true;
                              setState(() {

                              });
                              if(event.isIndividual())
                              {
                                if(await MongoDB.instance.joinEvent(event.id, FirebaseAuth.instance.currentUser!.uid))
                                {
                                  ScoreboardEntry s=new ScoreboardEntry(FirebaseAuth.instance.currentUser!.uid, null, 0);
                                  event.scoreboard!.add(s);
                                  LoggedUser.instance!.joinedEvents!.add(event);
                                  setState(() {
                                    _joined=!_joined;
                                  });
                                  widget.refresh();
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content:
                                      Text("You cannot join multiple active events simultaneously.")));
                                }
                              }
                              if(event.isTeam())
                              {
                                if(selectedTeam!=null)
                                {
                                  if(await MongoDB.instance.joinEvent(event.id, FirebaseAuth.instance.currentUser!.uid, teamId: selectedTeam!.id))
                                  {
                                    ScoreboardEntry s=new ScoreboardEntry(FirebaseAuth.instance.currentUser!.uid, selectedTeam!.id, 0);
                                    event.scoreboard!.add(s);
                                    LoggedUser.instance!.joinedEvents!.add(event);
                                    setState(() {
                                      _joined=!_joined;
                                    });
                                    widget.refresh();
                                  }
                                  else
                                  {
                                  }
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content:
                                      Text("Please select one team!")));
                                }

                              }
                            }
                            finally
                            {
                              joining=false;
                              setState(() {

                              });
                            }
                          }


                        }
                        }
                      )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
