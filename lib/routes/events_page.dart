import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/widget/event_item.dart';

class EventsPage extends StatefulWidget {
  EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Event> events = [];
  late bool hasSearched, loading;
  final eventSearchController = TextEditingController();

  @override
  void initState() {
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
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 3 * SizeConfig.heightMultiplier!),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 5 * SizeConfig.heightMultiplier!),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20.0,
                                //top: 1 * SizeConfig.heightMultiplier!,
                                right: 20),
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: CustomColors.green,
                              decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: CustomColors.silver,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: CustomColors.silver),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: CustomColors.green),
                                  ),
                                  hintText: "Search for an event",
                                  hintStyle:
                                      TextStyle(color: CustomColors.silver)),
                              controller: eventSearchController,
                              onSubmitted: (value) async {
                                if(eventSearchController.text!="")
                                  {
                                    setState(() {
                                      hasSearched = true;
                                      loading = true;
                                    });
                                    events = (await MongoDB.instance
                                        .searchEvent(eventSearchController.text, "", ""))!;
                                    setState(() {
                                      loading = false;
                                    });
                                  }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            !hasSearched
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
                        : Text("No events found")),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                "Joined Events",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 4 * SizeConfig.textMultiplier!,
                ),
              ),
            ),
            LoggedUser.instance!.joinedEvents!.length>0?ListView.builder(
                itemCount: LoggedUser.instance!.joinedEvents!.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, j) {
                  return EventItem(event: LoggedUser.instance!.joinedEvents![0], refresh: refresh,);
                }):Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*.025,),
                Text("Never joined and event.", style: TextStyle(fontSize: 15,),),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
