import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/loggedUser.dart';

import 'mongodb_service.dart';



Future<void> webSignInWithGoogle({required BuildContext context}) async {
  // Initialize Firebase
  User? user;

  // The `GoogleAuthProvider` can only be used while running on the web
  GoogleAuthProvider authProvider = GoogleAuthProvider();

  try {
    final UserCredential userCredential =
    await FirebaseAuth.instance.signInWithPopup(authProvider);

    user = userCredential.user;
  } catch (e) {
    print(e);
  }

  if (user != null) {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection("Users");
    QuerySnapshot querySnapshot = await usersCollection
        .where("Mail", isEqualTo: user.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      String? username = querySnapshot.docs[0].get("Username");
      if(username!=null)
        {
          LoggedUser.initInstance(user.uid, user.photoURL ?? "", user.email!, username);
          await MongoDB.instance.initUser(user.uid);
          Navigator.pushNamedAndRemoveUntil(context, '/web_dashboard', (route) => false);
        }
    }
  }
}