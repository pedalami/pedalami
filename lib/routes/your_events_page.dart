import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/utils/mobile_library.dart';
import 'package:pedala_mi/widget/request_item.dart';
import 'package:pedala_mi/widget/team_event_item.dart';



class YourEventsPage extends StatefulWidget {
  YourEventsPage({Key? key, required this.activeTeam}) : super(key: key);
  final Team activeTeam;
  @override
  _YourEventsPageState createState() => _YourEventsPageState();
}

class _YourEventsPageState extends State<YourEventsPage> {
  List<Event>? active_events = [];
  List<Event>? requested_events = [];
  late bool hasSearched, loading;
  late Team? actualTeam;

  @override
  void initState() {
    actualTeam=widget.activeTeam;
    loading = true;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
          //active_events = await MongoDB.instance.getTeamActiveEvents(actualTeam!.id);
          active_events =LoggedUser.instance!.getEventsOfTeam(actualTeam!.id);
          requested_events = await MongoDB.instance.getTeamEventRequests(actualTeam!.id);
          loading = false;
          setState(() {});
    });
    super.initState();
  }

  refresh(Event e, bool accepted){
    if(!accepted) {
      requested_events!.remove(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text("Event rejected!")));

    }
    else {
      active_events!.add(e);
      requested_events!.remove(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text("Event accepted!")));
    }
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.green[600],
                  height: 20 * SizeConfig.heightMultiplier!,
                  width: 100 * SizeConfig.widthMultiplier!,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 30.0,
                        right: 30.0,
                        top: 10 * SizeConfig.heightMultiplier!),
                    child: Column(
                      children: <Widget>[
                      Text(
                      "Your Team's Events",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 4 * SizeConfig.textMultiplier!,
                         ),
                        ),
                      ]
                    ),
                  ),
                ),
                  Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: loading?Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*.3,),
                            CircularProgressIndicator(),
                          ],
                        ):Column(
                            children: [
                              active_events!.length>0?ListView.builder(
                                  itemCount: active_events!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return TeamEventItem(event: active_events![i], activeTeam: widget.activeTeam,);
                                  }):Column(
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height*.025,),
                                        Text("You have no active events", style: TextStyle(fontSize: 15,
                                          color: Colors.black54,
                                        ),),
                                      ],
                                  ),

                              Padding(
                                padding: EdgeInsets.only(top: 15.0),
                                child: Text(
                                  "Private Event Requests",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 3 * SizeConfig.textMultiplier!,
                                  ),
                                ),
                              ),
                              requested_events!.length>0?ListView.builder(
                                  itemCount: requested_events!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, j) {
                                    return RequestItem(event: requested_events![j], refresh: refresh, activeTeam: widget.activeTeam,);
                                  }):Column(
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height*.025,),
                                        Text("You have no pending requests", style: TextStyle(fontSize: 15,
                                          color: Colors.black54,
                                        ),),
                                      ],
                                  ),
                            ],
                        ),
                      ),
                  ),
              ],
            ),
          ),
        ),
    );
  }
}


