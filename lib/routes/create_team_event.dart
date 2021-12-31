import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/size_config.dart';

class CreateTeamEvent extends StatefulWidget {
  const CreateTeamEvent({Key? key}) : super(key: key);

  @override
  _CreateTeamEventState createState() => _CreateTeamEventState();
}

class _CreateTeamEventState extends State<CreateTeamEvent> {
  final eventNameController=TextEditingController();
  DateTime selectedDate = DateTime.now();

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
                    Expanded(child: Text("Start Date: ")),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: Text(selectedDate.toString()),
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
                )
              ],
            ))


          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}
