import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/date_time_ext.dart';
import 'package:search_choices/search_choices.dart';

class CreateTeamEvent extends StatefulWidget {
  const CreateTeamEvent({Key? key, required this.actualTeam}) : super(key: key);
  final Team actualTeam;
  @override
  _CreateTeamEventState createState() => _CreateTeamEventState();
}

class _CreateTeamEventState extends State<CreateTeamEvent> {
  final eventNameController=TextEditingController();
  final descriptionNameController=TextEditingController();
  bool uploadingToDB=false;
  Team? selectedTeam;

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate=DateTime.now().add(Duration(days: 30));
  List<bool> publicOrPrivateEvent=[true,false];
  String opposingTeam="Choose an opposing team...";
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
                padding:
                EdgeInsets.only(top: 3 * SizeConfig.heightMultiplier!),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "Insert event details",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 10*SizeConfig.widthMultiplier!),
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 3*SizeConfig.heightMultiplier!),
                    child: TextField(
                      cursorColor: Colors.green,
                      decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: CustomColors.silver),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.green),
                          ),
                          hintText: "Event name",
                          hintStyle:
                          TextStyle(color: CustomColors.silver)),
                      controller: eventNameController,
                      maxLength: 20,
                      style: TextStyle(color: Colors.black),
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: 3*SizeConfig.heightMultiplier!),
                    child: TextField(
                      cursorColor: Colors.green,
                      decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: CustomColors.silver),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.green),
                          ),
                          hintText: "Description",
                          hintStyle:
                          TextStyle(color: CustomColors.silver)),
                      controller: descriptionNameController,
                      maxLength: 50,
                      style: TextStyle(color: Colors.black),
                    )),
                Padding(
                  padding: EdgeInsets.only(bottom: 3*SizeConfig.heightMultiplier!),
                  child: Row(
                    children: [
                      Expanded(flex:3,child: Text("Start Date: ",style: TextStyle(fontSize: 18))),
                      Expanded(
                        flex: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            _selectStartDate(context);
                          },
                          child: Text(selectedStartDate.formatITShort),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightGreen),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.lightGreen)))),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 3*SizeConfig.heightMultiplier!),
                  child: Row(
                    children: [
                      Expanded(flex:3,child: Text("End Date: ", style: TextStyle(fontSize: 18),),),
                      Expanded(
                        flex: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            _selectEndDate(context);
                          },
                          child: Text(selectedEndDate.formatITShort),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightGreen),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.lightGreen)))),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 3*SizeConfig.heightMultiplier!),
                  child: Row(
                    children: [
                      Expanded(flex:3,child: Text("Event type: ", style: TextStyle(fontSize: 18),),),
                      Expanded(
                        flex: 4,
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(18),
                          splashColor: Colors.grey,
                          color: Colors.grey,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          selectedColor: Colors.green,
                          borderColor: Colors.green,
                          selectedBorderColor: Colors.green,
                          children: <Widget>[
                            Container(
                              width:(MediaQuery.of(context).size.width-20*SizeConfig.widthMultiplier!)/10*2.5,
                                alignment: Alignment.center,
                                child: Text("Public", )),
                            Container(
                                width:(MediaQuery.of(context).size.width-20*SizeConfig.widthMultiplier!)/10*2.5,
                                alignment: Alignment.center,
                                child: Text("Private",)),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0; buttonIndex < publicOrPrivateEvent.length; buttonIndex++) {
                                if (buttonIndex == index) {
                                  publicOrPrivateEvent[buttonIndex] = true;
                                } else {
                                  publicOrPrivateEvent[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: publicOrPrivateEvent,
                        ),
                      ),
                    ],
                  ),
                ),
                publicOrPrivateEvent[1]?Padding(
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
                                        color: Colors.blue,
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
                Padding(
                  padding: EdgeInsets.only(bottom: 3*SizeConfig.heightMultiplier!),
                  child: !uploadingToDB?ElevatedButton(
                    onPressed: () async{
                      if(eventNameController.text.trim()!="")
                        {
                          if(descriptionNameController.text.trim()!="")
                            {
                              setState(() {
                                uploadingToDB=true;
                              });
                              if(publicOrPrivateEvent[0])
                              {
                                Event? event=await MongoDB.instance.createPublicTeamEvent(actualTeam.adminId, actualTeam.id, eventNameController.text.trim(), descriptionNameController.text.trim(), selectedStartDate, selectedEndDate);
                                setState(() {
                                  uploadingToDB=false;
                                });
                                if(event!=null)
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content:
                                      Text("Public event sent correctly!")));
                                  Navigator.of(context).pop();
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content:
                                      Text("Please try again!")));
                                }
                              }
                              else if(publicOrPrivateEvent[1])
                              {
                                if(selectedTeam!=null)
                                {
                                  Event? event=await MongoDB.instance.createPrivateTeamEvent(actualTeam.adminId, actualTeam.id, selectedTeam!.id, eventNameController.text.trim(), descriptionNameController.text.trim(), selectedStartDate, selectedEndDate);
                                  setState(() {
                                    uploadingToDB=false;
                                  });
                                  if(event!=null)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content:
                                        Text("Private event created correctly!")));
                                    Navigator.of(context).pop();
                                  }
                                  else
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content:
                                        Text("Please try again!")));
                                  }
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content:
                                      Text("Please select one opposing team!")));
                                }
                              }
                            }
                          else
                            {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content:
                                  Text("Please write a description for this event!")));
                            }

                        }
                      else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                              Text("Please write a name for this event!")));
                        }
                    },
                    child: Container(
                      alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width*.15,
                        height: MediaQuery.of(context).size.width*.1,
                        child: Text("Confirm")),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Colors.lightGreen),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: Colors.lightGreen)))),
                  ):CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(CustomColors.green),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 30)));
    if (picked != null && picked != selectedStartDate)
      if(picked.isBefore(selectedEndDate))
        {
          setState(() {
            selectedStartDate = picked;
          });
        }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
              Text("You cannot select the start date after the end date!")));
        }

  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 30)));
    if (picked != null && picked != selectedEndDate)
      if(picked.isAfter(selectedStartDate))
        {
          setState(() {
            selectedEndDate = picked;
          });
        }
    else
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text("You cannot select the end date before the start date!")));
      }

  }
}
