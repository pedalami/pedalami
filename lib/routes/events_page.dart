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
  List<Event> activeUserEvents=[];
  bool loadingActiveEvents=true;
  late bool hasSearched, loading;
  final eventSearchController = TextEditingController();

  @override
  void initState() {
    hasSearched = false;
    loading = false;
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async{
      activeUserEvents=(await MongoDB.instance.getUserEvents(user!.uid))!;
      loadingActiveEvents=false;
      setState(() {

      });
    });
  }

  refresh(Event e){
    activeUserEvents.add(e);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
                                decoration: InputDecoration(
                                    counterStyle: TextStyle(
                                      color: CustomColors.silver,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide:
                                          BorderSide(color: Colors.white),
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
                                          .getJoinableEvents(FirebaseAuth.instance.currentUser!.uid,eventSearchController.text,))!;
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
              AnimatedSwitcher(duration: Duration(milliseconds: 250),
              child: loadingActiveEvents?CircularProgressIndicator():activeUserEvents.length>0?ListView.builder(
                  itemCount: activeUserEvents.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, j) {
                    return EventItem(event: activeUserEvents[j], refresh: refresh,);
                  }):Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*.025,),
                  Text("Never joined and event.", style: TextStyle(fontSize: 15,
                    color: Colors.black54,
                  ),),
                ],
              ),),


            ],
          ),
        ),
      )),
    );
  }
}
