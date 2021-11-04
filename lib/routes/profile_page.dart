import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    User? user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.1,
                0.5,
                0.7,
                0.9
              ],
              colors: [
                Colors.green[800]!,
                Colors.green[700]!,
                Colors.green[600]!,
                Colors.green[400]!,
              ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Text(nStringToNNString(user!.displayName)),
                  Text(nStringToNNString(user.email)),
                  Text(nStringToNNString(user.uid)),
                  ],
              ),
            ),
          ),
        ),
      ),
    );


  }
  String nStringToNNString(String? str) {
    return str ?? "";
  }
}