import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mongodb_service.dart';

Future<void> webSignInWithGoogle({required BuildContext context}) async {
  User? user;
  GoogleAuthProvider authProvider = GoogleAuthProvider();
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(authProvider);
    user = userCredential.user;
  } catch (e) {
    print(e);
  }
  if (user != null) {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("Users");
    QuerySnapshot querySnapshot =
        await usersCollection.where("Mail", isEqualTo: user.email).get();
    if (querySnapshot.docs.isNotEmpty) {
      String? username = querySnapshot.docs[0].get("Username");
      if (username != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("loggedIn", true);
        LoggedUser.initInstance(
            user.uid, user.photoURL ?? "", user.email!, username);
        await MongoDB.instance.initUser(user.uid);
        LoggedUser.instance!.setRideHistory(
          await MongoDB.instance.getAllRidesFromUser(LoggedUser.instance!.userId));
        print("userId of the logged user is: " + LoggedUser.instance!.userId);
        Navigator.pushNamedAndRemoveUntil(
            context, '/web_dashboard', (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "You're not registered. To do so, download the PedalaMi app!",
          style: TextStyle(letterSpacing: 0.5),
        ),
      ));
      FirebaseAuth.instance.signOut();
      GoogleSignIn().signOut();
    }
  }
}

Future<void> webSignOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("loggedIn");
  Navigator.pushNamedAndRemoveUntil(context, '/sign_in_page', (route) => true);
}
