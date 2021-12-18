import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json;
import "package:http/http.dart" as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as aIcon;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:pedala_mi/utils/get_device_type.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    User result = FirebaseAuth.instance.currentUser!;
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
            Colors.green[700]!,
            Colors.green[600]!,
            Colors.green[500]!,
            Colors.green[400]!,
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            child: Column(
              children: [
                pedalaLogo(context, size),
                signUpButton(context, result),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget pedalaLogo(context, size) {
  return Padding(
    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height) / 8,
    child: Container(
      child: Image(
        image: AssetImage('lib/assets/pedala_logo.png'),
        height: size.height / 2,
      ),
    ),
  );
}

Widget signUpButton(context, result) {
  return OutlinedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ))),
      onPressed: () {

        if(result == null){
          Navigator.pushNamed(context, '/sign_in');
        }
        else{
          if(getSmartPhoneOrTablet() == 'desktop'){
            Navigator.pushNamed(context, '/web_dashboard');
          }
          else{
            Navigator.pushNamed(context, '/switch_page');
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('lib/assets/google_logo.png'),
              height: 35.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Sign in with Google",
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ));
}
