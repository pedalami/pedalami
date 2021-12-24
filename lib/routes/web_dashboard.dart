import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/services/web_authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebDashBoard extends StatefulWidget {
  final context;

  const WebDashBoard({Key? key, this.context}) : super(key: key);

  @override
  _WebDashBoardState createState() => _WebDashBoardState();
}

class _WebDashBoardState extends State<WebDashBoard> {
  LoggedUser? _miUser = LoggedUser.instance;


  @override
  void initState() {
    super.initState();
  }

  Widget showStats() {
    return _miUser == null
        ? Container(
            height: MediaQuery.of(context).size.height / 5,
            width: MediaQuery.of(context).size.width / 8,
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              backgroundColor: Colors.grey,
            ),
          )
        : Row(
            children: [
              Column(
                children: [
                  Text("HEJ"),
                ],
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 8,
        leadingWidth: MediaQuery.of(context).size.width / 8,
        leading: Transform.scale(
          scale: 3,
          child: Padding(
            padding: EdgeInsets.only(top: 5.0, left: 5),
            child: Image.asset(
              'lib/assets/pedala_logo.png',
              height: MediaQuery.of(context).size.height / 10,

            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width / 90,
              top: MediaQuery.of(context).size.height / 90,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _miUser!=null?Text(_miUser!.username):SizedBox(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 90,
                    ),
                    _miUser!=null?Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _miUser!.image,
                          )),
                    ):Container(
                      height: 50,
                      width: 50,
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove("loggedIn");
                    await webSignOut(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 90),
                    child: Row(
                      children: [
                        Text(
                          "Logout",
                          style: TextStyle(color: Colors.green),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 90,
                        ),
                        FaIcon(
                          FontAwesomeIcons.signOutAlt,
                          color: Colors.green,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
        backgroundColor: Colors.green.shade200,
      ),
      body: Center(child: showStats()),
    );
  }
}
