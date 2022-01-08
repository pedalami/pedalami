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

class RequestItem extends StatefulWidget {
  const RequestItem({Key? key, required Event event, required refresh, required this.activeTeam}) : refresh=refresh,event=event,super(key: key);
  final Function refresh;
  final Event event;
  final Team activeTeam;

  @override
  _RequestItemState createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {

  late Event event;
  late Team team;
  late Team? opposingName;
  bool loadingOpponentTeam = true;
  late bool _accepted, _rejected, _visible;


  @override
  void initState() {
    event=widget.event;
    team=widget.activeTeam;
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      opposingName = (await MongoDB.instance.getTeam(event.involvedTeamsIds!.first))!;  //gets event's hosting team's details
      print(opposingName!.name);
      loadingOpponentTeam=false;
      setState(() {});
    });
    _accepted=false;
    _rejected=false;
    _visible=true;

  }

  refresh() {
    widget.refresh();
    setState(() {});
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
                        !loadingOpponentTeam?
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("OPPOSING TEAM: "+opposingName!.name,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ):Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("OPPOSING TEAM: ",
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
                          child: Text("START: "+event.startDate.formatIT,
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
                          child: Text("ENDS:    "+event.endDate.formatIT,
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
                  Column(
                    children: [
                      AnimatedOpacity(
                            opacity: _visible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: ElevatedButton(
                              style: !_accepted?ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.lightGreen)))):ButtonStyle(
                              ),
                              child: Text("Accept"),
                              onPressed: () async{
                                _accepted = await MongoDB.instance.acceptInvite(event.id, team.adminId, team.id);
                                print("accepted: "+_accepted.toString());
                                  setState(() {
                                    if(_accepted)
                                      _visible = !_visible;
                                  });
                                 widget.refresh();
                                }
                          ),
                      ),
                      AnimatedOpacity(
                        opacity: _visible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: ElevatedButton(
                            style: !_rejected?ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.redAccent)))):ButtonStyle(
                            ),
                            child: Text(" Reject "),
                            onPressed: () async{
                              _rejected = await MongoDB.instance.rejectInvite(event.id, team.adminId, team.id);
                              print("rejected: "+_rejected.toString());
                              setState(() {
                                if(_rejected)
                                _visible = !_visible;
                              });
                              widget.refresh();
                            }
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
