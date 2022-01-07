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
import 'package:search_choices/search_choices.dart';

class TeamEventItem extends StatefulWidget {
  const TeamEventItem({Key? key, required Event event, required refresh, required this.activeTeam}) : refresh=refresh,event=event,super(key: key);
  final Function refresh;
  final Event event;
  final Team activeTeam;

  @override
  _TeamEventItemState createState() => _TeamEventItemState();
}

class _TeamEventItemState extends State<TeamEventItem> {

  late Event event;
  late bool _rejected, _invited, _visible;
  late Team active;

  Team? selectedTeam;
  late Team? opposingName;
  var selectedValueSingleDialogFuture;
  bool loadingOpponentTeam = true;

  @override
  void initState() {
    event=widget.event;
    _rejected=false; //TODO: get this value (as true from Reject button onPressed()) if the private team event request is rejected...
    _visible=true;
    active=widget.activeTeam;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      opposingName = (await MongoDB.instance.getTeam(event.enrolledTeamsIds![1]))!;  //gets event's opposing team's details
      print(opposingName!.name);
      loadingOpponentTeam=false;
      setState(() {});
    });
    super.initState();
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
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("Hosting Team: "+active.name,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        ),
                        event.isPrivate()&&!loadingOpponentTeam&&opposingName!.name!=active.name?
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("Opposing Team: "+opposingName!.name,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeConfig.textMultiplier!
                            ),
                          ),
                        )://event.isPrivate() && !loadingOpponentTeam && opposingName==null?
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1 * SizeConfig.heightMultiplier!),
                          child: Text("Opposing Team: ---",
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
    //****************************************************//
    //TODO: If private team event request is rejected...this code should execute
                        _rejected?Padding(
                          padding: EdgeInsets.only(bottom: 3*SizeConfig.heightMultiplier!),
                          child: Row(
                            children: [
                              Expanded(flex:3,child: Text("Opposing team: ", style: TextStyle(fontSize: 18),),),
                              Expanded(
                                  flex: 5,
                                  child:
                                  SearchChoices.single(
                                    value: selectedValueSingleDialogFuture,
                                    hint: "Choose an opposing team...",
                                    searchHint: "Write an opposing team...",
                                    onChanged:  (value) {
                                      setState(() {
                                        selectedValueSingleDialogFuture = value;
                                      });
                                    },
                                    isExpanded: true,
                                    selectedValueWidgetFn: (item) {
                                      selectedTeam=(item as Team);
                                      return (Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(selectedTeam!.name),
                                          )));
                                    },
                                    futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
                                        List<Tuple2<String, String>>? filters, int? pageNb) async {
                                      int nbResults=0;
                                      List<DropdownMenuItem> results=[];
                                      if(keyword!="")
                                      {
                                        List<Team>? teamsFound=await MongoDB.instance.searchTeam(keyword!);
                                        int sameTeamIndex=-1;
                                        for(int i=0;i<teamsFound!.length;i++)
                                        {
                                          if(teamsFound[i].id==active.id)
                                          {
                                            sameTeamIndex=i;
                                          }
                                        }
                                        if(sameTeamIndex!=-1)
                                        {
                                          teamsFound.removeAt(sameTeamIndex);
                                        }
                                        nbResults=teamsFound.length;
                                        results=teamsFound.map<DropdownMenuItem>((item) => DropdownMenuItem(
                                          value: item,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                              side: BorderSide(
                                                color: Colors.green,
                                                width: 1,
                                              ),
                                            ),
                                            margin: EdgeInsets.all(1),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(item.name),
                                            ),
                                          ),
                                        )).toList();
                                      }
                                      return (Tuple2<List<DropdownMenuItem>, int>(results, nbResults));
                                    },
                                    emptyListWidget: () => Text(
                                      "No result",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ):SizedBox(),
                        _rejected?
                        Align(alignment: Alignment.center,
                          child: AnimatedOpacity(
                            opacity: _visible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: ElevatedButton(
                                style: _rejected?ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.lightGreen)))):ButtonStyle(
                                ),
                                child: Text("Invite Team"),
                                onPressed: () async{
                                  _invited = await MongoDB.instance.sendInvite(event.id, active.adminId, event.enrolledTeamsIds![0], selectedTeam!.id);
                                  print("Invited: "+_invited.toString());
                                  setState(() {
                                    if(_invited)
                                      _rejected = false;
                                    });
                                  widget.refresh();
                                }
                            ),
                          ),
                        ):SizedBox(),
    //****************************************************//
                      ],
                    ),
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
