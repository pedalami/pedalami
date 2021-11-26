import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/routes/sign_in_page.dart';



Widget buildCustomAlertOKDialog(
    BuildContext context, String topText, String message) {
  return AlertDialog(
    backgroundColor: Colors.white,
    title: Text(
      topText,
      style: TextStyle(color: Colors.black),
    ),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(
            message,
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
        },
      ),
    ],
  );
}

Route _routeToSignInScreen() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
