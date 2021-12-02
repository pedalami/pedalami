import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/custom_alert_dialog.dart';


class TeamCreation extends StatefulWidget {
  TeamCreation({Key? key}) : super(key: key);

  @override
  _TeamCreationState createState() => _TeamCreationState();
}

class _TeamCreationState extends State<TeamCreation> {

  final teamNameController=TextEditingController();
  final descriptionController=TextEditingController();
  FocusNode _focusName = new FocusNode();
  FocusNode _focusDescription = new FocusNode();

  @override
  void initState() {
    _focusName.addListener(_onFocusChange);
    _focusDescription.addListener(_onFocusChange);
    super.initState();
  }
  @override
  void dispose(){
    _focusName.removeListener(_onFocusChange);
    _focusName.dispose();
    _focusDescription.removeListener(_onFocusChange);
    _focusDescription.dispose();
    super.dispose();
  }

  void _onFocusChange(){
setState(() {

});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            color: Colors.green[600],
            height: 40 * SizeConfig.heightMultiplier!,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 10 * SizeConfig.heightMultiplier!),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                          child: Container(

                            height: 11 * SizeConfig.heightMultiplier!,
                            width: 22 * SizeConfig.widthMultiplier!,
                            decoration: BoxDecoration(
                              color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("lib/assets/app_icon.png")
                                )),
                          ),
                          onTap: ()  {

                          }),
                      SizedBox(
                        width: 5 * SizeConfig.widthMultiplier!,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*.5,
                            child: Expanded(
                              child: Text(
                                teamNameController.text.isEmpty?"Your new team":teamNameController.text,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 3 * SizeConfig.textMultiplier!,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 1 * SizeConfig.heightMultiplier!,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width*.5,
                                child: Expanded(
                                  child: Text(
                                    descriptionController.text,
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize:
                                      1.5 * SizeConfig.textMultiplier!,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 35 * SizeConfig.heightMultiplier!),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )),
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                left: 10.0,
                                top: 25,
                                right: 10),
                            child: TextField(

                              cursorColor: CustomColors.green,
                              decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: CustomColors.silver,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CustomColors.silver),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CustomColors.green),
                                  ),
                                  hintText: "Insert the name of the team",
                                  hintStyle:
                                  TextStyle(color: CustomColors.silver)),
                              controller: teamNameController,
                              focusNode: _focusName,
                              maxLength: 20,
                              style: TextStyle(color: Colors.black),
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 10.0,
                                top: 10 ,
                                right: 10),
                            child: TextField(
                              focusNode: _focusDescription,
                              cursorColor: CustomColors.green,
                              decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: CustomColors.silver,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CustomColors.silver),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CustomColors.green),
                                  ),
                                  hintText: "Insert a brief description",
                                  hintStyle:
                                  TextStyle(color: CustomColors.silver)),
                              controller: descriptionController,
                              maxLength: 100,
                              style: TextStyle(color: Colors.black),
                            )),
                        Container(
                          child: ElevatedButton(
                              onPressed: () async{
                                if(await MongoDB.instance.createTeam(FirebaseAuth.instance.currentUser!.uid, teamNameController.text, descriptionController.text)!=null)
                                  {

                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text(
                                            "Success",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(
                                                  "Your team has been created successfully!",
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                'OK',
                                                style: TextStyle(color: CustomColors.green),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );

                                      },
                                    );
                                  }
                                else
                                  {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        "An error occurred, please try again.",),
                                    ));
                                  }
                              },
                              child: Text("Create team"),
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      Size(200, 35)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0))))),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              top: 3 * SizeConfig.heightMultiplier!,
                              right: 10.0),
                        ),
                        SizedBox(
                          height: 30 * SizeConfig.heightMultiplier!,
                        ),
                        Container(
                          height: 20 * SizeConfig.heightMultiplier!,
                        ),
                        Divider(
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
