import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/widget/event_item.dart';

class YourEventsPage extends StatefulWidget {
  YourEventsPage({Key? key, required this.activeTeam}) : super(key: key);
  final Team activeTeam;
  @override
  _YourEventsPageState createState() => _YourEventsPageState();
}

class _YourEventsPageState extends State<YourEventsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Event> events = [];
  late bool hasSearched, loading;
  late Team? actualTeam;
  //final eventSearchController = TextEditingController();

  displayYourEvents() async{
    events= (await MongoDB.instance.searchEvent("", actualTeam!.name, actualTeam!.adminId))!;
  }

  @override
  void initState() {
    actualTeam=widget.activeTeam;
    hasSearched = false;
    loading = false;
    //events = displayYourEvents(); // as List<Event>;
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
                      ],
                    ),
                  ),
                ),
                /*!hasSearched
                    ? SizedBox()
                    : loading
                    ? Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width*.05,),
                    CircularProgressIndicator(color: Colors.green[600],),
                    SizedBox(height: MediaQuery.of(context).size.width*.05,),
                    Text("Loading", style: TextStyle(fontSize: 17),)
                  ],
                )
                    : (events.length > 0
                    ? Column(
                  children: [Container(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          "Available Events",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 4 * SizeConfig.textMultiplier!,
                          ),
                        ),
                      ),
                    ),
                  ),
                    ListView.builder(
                        itemCount: events.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return EventItem(event: events[i], refresh: refresh,);
                        }),
                  ],
                )
                    : Text("No events found")),*/
                events.length>0?ListView.builder(
                    itemCount: events.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, j) {
                      return EventItem(event: events[0], refresh: refresh,);
                    }):Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*.025,),
                    Text("You have no created events", style: TextStyle(fontSize: 15,),),
                  ],
                ),
                Divider(
                  color: Colors.grey[500],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    "Private Event Requests",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 3 * SizeConfig.textMultiplier!,
                    ),
                  ),
                ),
                events.length>0?ListView.builder(
                    itemCount: events.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, j) {
                      return EventItem(event: events[0], refresh: refresh,);
                    }):Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*.025,),
                    Text("You have no pending requests", style: TextStyle(fontSize: 15,),),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}


