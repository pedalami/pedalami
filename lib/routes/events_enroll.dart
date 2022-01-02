import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/mobile_library.dart';
import 'package:search_choices/search_choices.dart';

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

  List<bool> publicOrPrivateEvent=[true,false];
  String enrollEvent="Search for an event...";
  late Team actualTeam;
  var selectedValueSingleDialogFuture;


  @override
  void initState() {
    actualTeam=widget.actualTeam;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.green[600],
              height: 20 * SizeConfig.heightMultiplier!,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(top: 10*SizeConfig.heightMultiplier!),
                child:
                  Column(
                  children: [ Text(
                    "Enroll to Events",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 4 * SizeConfig.textMultiplier!,
                    ),
                  ),],
                 ),
               ),

             ),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(top: 3*SizeConfig.heightMultiplier!, bottom:  3*SizeConfig.heightMultiplier!),
                child: Row(
                  children: [
                    Expanded(flex:3,child: Text("Search for an event: ", style: TextStyle(fontSize: 18),),),
                    Expanded(
                        flex: 5,
                        child:
                        SearchChoices.single(
                          value: selectedValueSingleDialogFuture,
                          hint: "Search an event...",
                          searchHint: "Choose an event to enroll...",
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
                              //should be await MongoDB.instance.searchEvent, not getJoinableEvents
                              /*List<Event>? teamsFound=await MongoDB.instance.getJoinableEvents(LoggedUser.instance!.userId);
                              int sameTeamIndex=-1;
                              for(int i=0;i<teamsFound!.length;i++)
                              {
                                if(teamsFound[i].id==actualTeam.id)
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
                              )).toList();*/
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
              ),
            )
          ],
        ),
      ),
    );
  }


}
