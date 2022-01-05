import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/mobile_library.dart';
import 'package:search_choices/search_choices.dart';
import 'package:pedala_mi/widget/enroll_item.dart';

class EnrollEvent extends StatefulWidget {
  const EnrollEvent({Key? key, required this.actualTeam}) : super(key: key);
  final Team actualTeam;
  @override
  _EnrollEventState createState() => _EnrollEventState();
}

class _EnrollEventState extends State<EnrollEvent> {
  final eventNameController=TextEditingController();
  final descriptionNameController=TextEditingController();
  bool uploadingToDB=false;
  Team? selectedTeam;
  List<Event> events = [];

  List<bool> publicOrPrivateEvent=[true,false];
  String enrollEvent="Search for an event...";
  late Team actualTeam;
  var selectedValueSingleDialogFuture;
  final eventSearchController = TextEditingController();
  late bool hasSearched, loading;

  refresh(){
    setState((){});
  }

  @override
  void initState() {
    hasSearched = false;
    loading = false;
    actualTeam=widget.actualTeam;
    super.initState();
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
                  height: 30 * SizeConfig.heightMultiplier!,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 30.0,
                        right: 30.0,
                        top: 8 * SizeConfig.heightMultiplier!),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Enroll to Events",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 4 * SizeConfig.textMultiplier!,
                          ),
                        ),
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
                                      events = (await MongoDB.instance.searchEvent(eventSearchController.text, actualTeam.id, actualTeam.adminId))!;
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
                          return EnrollItem(event: events[i], refresh: refresh,);
                        }),
                  ],
                )  : Padding( padding: EdgeInsets.only(top: 15),
                     child: Text("No events found"))),
              ],
            ),
          ),
        ));
  }
}



