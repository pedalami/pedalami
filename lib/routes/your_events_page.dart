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
import 'package:pedala_mi/widget/event_item.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';


class YourEventsPage extends StatefulWidget {
  YourEventsPage({Key? key, required this.activeTeam}) : super(key: key);
  final Team activeTeam;
  @override
  _YourEventsPageState createState() => _YourEventsPageState();
}

class _YourEventsPageState extends State<YourEventsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Event> active_events = [];  //TODO: will be replaced with a list from Team property - activeTeam.activeEvents as in DB now
  List<Event> requested_events = []; //TODO: will be replaced with a list from Team property - activeTeam.eventRequests as in DB now
  late bool hasSearched, loading;
  late Team? actualTeam;
  //final eventSearchController = TextEditingController();

  getYourEvents() async{
    active_events = (await MongoDB.instance.getTeamActiveEvents(actualTeam!.id))!;
    //active_events = (await MongoDB.instance.getTeamActiveEvents("61b7e246f34ee1e975875025"))!;
    print(active_events.length);
  }

  getYourRequests() async{
    requested_events = (await MongoDB.instance.getTeamEventRequests(actualTeam!.id))!;
    //requested_events = (await MongoDB.instance.getTeamEventRequests("61b7e246f34ee1e975875025"))!;
    print(requested_events.length);
  }

  @override
  void initState() {
    actualTeam=widget.activeTeam;
    hasSearched = false;
    loading = false;
    super.initState();
  }

  refresh(){
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
                      "Your Events",
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
                      child: Column(
                          children: [
                            displayActiveEvents(),
                            SizedBox(height: MediaQuery.of(context).size.height*.02,),
                            /*active_events.length>0?ListView.builder(
                                itemCount: active_events.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, j) {
                                  return EventItem(event: active_events[0], refresh: refresh,);
                                }):Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*.025,),
                                      Text("You have no active events", style: TextStyle(fontSize: 15,),),
                                    ],
                                ),*/
                            Divider(
                                  color: Colors.grey[500],
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
                            displayEventRequests(),
                            SizedBox(height: MediaQuery.of(context).size.height*.02,),
                            /*requested_events.length>0?ListView.builder(
                                itemCount: requested_events.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, j) {
                                  return EventItem(event: requested_events[0], refresh: refresh,);
                                }):Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*.025,),
                                      Text("You have no pending requests", style: TextStyle(fontSize: 15,),),
                                    ],
                                ),*/
                          ],
                      ),
                  ),
              ],
            ),
          ),
        ),
    );
  }

  Widget displayActiveEvents() {
    getYourEvents();
    return ListView.builder(
        //itemCount: actualTeam.activeEvents!.length ?? 0,
        itemCount: active_events.length ?? 0, //TODO: Will be replaced with actualTeam.activeEvents!.length
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Stack(
              children: [
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: AssetImage('lib/assets/app_logo.png'),
                          height: 16 * SizeConfig.heightMultiplier!,
                          width: 32 * SizeConfig.widthMultiplier!,
                        ),
                      ),],
                  ),
                  onTap: () {
                    //TODO open event info
                  },
                ),
                Positioned.fill(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          actualTeam!.name + "team's active event", //TODO Replace with next line
                          //actualTeam!.activeEvents![index].name,
                          style: TextStyle(
                              fontSize: 2 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        )))
              ],
            ),
            onTap: () {},
          );
    });
  }

  Widget displayEventRequests() {
    getYourRequests();
    return ListView.builder(
      //itemCount: actualTeam.eventRequests!.length ?? 0,
        itemCount: requested_events.length ?? 0, //TODO: Will be replaced with actualTeam.eventRequests!.length
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Stack(
              children: [
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: AssetImage('lib/assets/app_logo.png'),
                          height: 16 * SizeConfig.heightMultiplier!,
                          width: 32 * SizeConfig.widthMultiplier!,
                        ),
                      ),],
                  ),
                  onTap: () {
                    //TODO open event information
                  },
                ),
                Positioned.fill(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          actualTeam!.name + "team's event request", //TODO Replace with next line
                          //actualTeam!.eventRequests![index].name,
                          style: TextStyle(
                              fontSize: 2 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        )))
              ],
            ),
            onTap: () {},
          );
    });
  }
}


