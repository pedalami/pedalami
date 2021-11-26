
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
            Container(
                color: Colors.green[600],
                height: 45 * SizeConfig.heightMultiplier!,
                width: 100 * SizeConfig.heightMultiplier!,
                child: Padding(
                    padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 10 * SizeConfig.heightMultiplier!),
                    child: Column(
                    children: <Widget>[],
                    ),
                ),
            ),
        ],
    ));
  }
  }

