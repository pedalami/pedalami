import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/date_time_ext.dart';

class CreateTeamEvent extends StatefulWidget {
  const CreateTeamEvent({Key? key}) : super(key: key);

  @override
  _CreateTeamEventState createState() => _CreateTeamEventState();
}

class _CreateTeamEventState extends State<CreateTeamEvent> {
  final eventNameController=TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate=DateTime.now().add(Duration(days: 30));
  List<bool> isSelected=[true,false];
  String opposingTeam="Choose an opposing team...";

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
                Row(
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
                Row(
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
                Row(
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
                            for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected,
                      ),
                    ),
                  ],
                ),
                isSelected[1]?Row(
                  children: [
                    Expanded(flex:3,child: Text("Opposing team: ", style: TextStyle(fontSize: 18),),),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: () {
                          if(isSelected[1])
                            {

                            }
                        },
                        child: Text(opposingTeam, textAlign: TextAlign.center,),
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
                ):SizedBox(),
                ElevatedButton(
                  onPressed: () {

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
