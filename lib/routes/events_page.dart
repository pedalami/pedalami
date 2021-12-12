
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';



class EventsPage extends StatefulWidget {
  EventsPage({Key? key}) : super(key: key);
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container (
                child: Padding(
                    padding: EdgeInsets.only(
                    left: 13 * SizeConfig.heightMultiplier!,
                    top: 12 * SizeConfig.heightMultiplier!),
                        child: Text( "Active Events",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 4 * SizeConfig.textMultiplier!,),
                  ),
                ),
              ),
            Container(
                child: Padding(
                    padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 20 * SizeConfig.heightMultiplier!),
                    child: Column(
                    children: <Widget>[
                      Container(
                        height: 22 * SizeConfig.heightMultiplier!,
                          width: 150 * SizeConfig.widthMultiplier!,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                            // TODO: insert events icon <----
                            /*image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          nStringToNNString(_miUser.image)),*/
                          ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                                child: Text("Event Name: \"Rough Bikers only\"",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 2 * SizeConfig.textMultiplier!
                                  ),
                                ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Points: 300",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Event Type: Individual",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Ends: 31/February/2056",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  top: 1 * SizeConfig.heightMultiplier!,
                                  right: 10),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text("Leave event", style: TextStyle(color: Colors.black),),
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all(
                                        Size(200, 35)),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.redAccent),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: Colors.redAccent)))),
                              ),
                            ),
                          ],
                        ),
                        ),
                        SizedBox(
                          height: 5 * SizeConfig.widthMultiplier!,
                        ),
                      Container (
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 1 * SizeConfig.heightMultiplier!,
                              top: 2 * SizeConfig.heightMultiplier!,
                              bottom: 2 * SizeConfig.heightMultiplier!),
                          child: Text( "Available Events",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 4 * SizeConfig.textMultiplier!,),
                          ),
                        ),
                      ),
                      Container(
                        height: 22 * SizeConfig.heightMultiplier!,
                        width: 150 * SizeConfig.widthMultiplier!,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.green, width: 2),

                            borderRadius: BorderRadius.all(Radius.circular(20))
                          /*image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          nStringToNNString(_miUser.image)),*/
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Event Name: \"Long ride!\"",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Points: 100",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Event Type: 1 vs 1",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Text("Ends: 1/January/2022",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier!
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  top: 1 * SizeConfig.heightMultiplier!,
                                  right: 10),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text("Join Event"),
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all(
                                        Size(200, 35)),
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
                        // TODO: END <-----
                      ),
                      ],
                    ),
                ),
            ),
        ],
    ));
  }
  }

