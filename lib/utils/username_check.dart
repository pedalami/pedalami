import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/widget/custom_alert_dialog.dart';
import 'package:uuid/uuid.dart';


Future<void> checkUsername(String newUsername, BuildContext context,
    User actualUser, String imageData) async {
  if (newUsername.trim().length < 5) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return buildCustomAlertOKDialog(context, "Warning",
            "Please use an username with at least 5 characters.");
      },
    );
  } else {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("Users");
    usersCollection
        .where("Username", isEqualTo: newUsername.trim())
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return buildCustomAlertOKDialog(
                context, "Warning", "This username is already taken.");
          },
        );
      } else {
        var uuid = Uuid().v4();
        Map<String, Object> user = new HashMap();
        user["Mail"] = actualUser.email!;
        user["Username"] = newUsername.trim();
        user["userId"] = actualUser.uid;
        File image = File(imageData);
        Reference imageRef = FirebaseStorage.instance.ref().child(uuid.toString() + ".jpg");
        await imageRef.putFile(image);
        await imageRef.getDownloadURL().then((url) {
          user["Image"] = url;
          FirebaseFirestore.instance
              .collection("Users")
              .add(user)
              .then((value) async {
            LoggedUser.initInstance(actualUser.uid, actualUser.photoURL ?? "", actualUser.email!, newUsername.trim());
            await MongoDB.instance.initUser(actualUser.uid);
            Navigator.pushNamedAndRemoveUntil(context, '/switch_page', (route) => false);
          }).catchError((error) {});
        }).catchError((error) {});
      }
    });
  }

}

Future<void>updateUsername(String newUsername, BuildContext context) async {
  if (newUsername.trim().length < 5) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return buildCustomAlertOKDialog(context, "Warning",
            "Please use an username with at least 5 characters.");
      },
    );
  } else {
    String trimmedUsername=newUsername.trim();
    CollectionReference usersCollection = FirebaseFirestore.instance.collection("Users");
    usersCollection
        .where("Username", isEqualTo: trimmedUsername)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return buildCustomAlertOKDialog(
                context, "Warning", "This username is already taken.");
          },
        );
      } else {
        String docID="";
        await usersCollection
            .where("Mail", isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .get()
            .then((QuerySnapshot querySnapshot) async {
          docID=querySnapshot.docs[0].id;
        });
        FirebaseFirestore.instance
            .collection("Users")
            .doc(docID)
            .update({'Username': trimmedUsername}).then((value) async {
          LoggedUser.instance!.updateUsername(trimmedUsername);
          Navigator.pop(context);
          return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return buildCustomAlertOKDialog(
                    context, "", "Username changed correctly.");
              });
        });
      }
    });
  }
}
