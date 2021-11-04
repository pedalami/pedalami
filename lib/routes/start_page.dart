import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json;
import "package:http/http.dart" as http;

import 'package:google_sign_in/google_sign_in.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? result = FirebaseAuth.instance.currentUser;
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
        body: Center(
          child: Container(
            child: Column(
              children: [
                pedalaLogo(context),
                SizedBox(height: 100,),
                signUpButton(context, result),
                SizedBox(height: 20,),
                loginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget pedalaLogo(context) {
  return Padding(
    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height) / 4,
    child: Container(
      child: Text("Text here"),
    ),
  );
}

Widget signUpButton(context, result) {
  return Container(
    child: ElevatedButton(
      child: Text("Sign in with google"),
      onPressed: () {
        result == null
            ? Navigator.pushNamed(context, '/sign_in')
            : Navigator.pushNamed(context, '/profile');
      },
    ),
  );
}

Widget loginButton(context) {
  return Container(
    child: ElevatedButton(child: Text("Create an account"), onPressed: () {}),
  );
}
