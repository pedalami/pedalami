import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/username_insert_page.dart';
import 'mongodb_service.dart';


class Authentication {
  static Future initializeFirebase({ required BuildContext context }) async {
    await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (!user.isAnonymous) {
        CollectionReference usersCollection = FirebaseFirestore.instance.collection("Users");
        QuerySnapshot querySnapshot = await usersCollection
          .where("Mail", isEqualTo: user.email)
          .get();
        if (querySnapshot.docs.isNotEmpty) {
          String? username = querySnapshot.docs[0].get("Username");
          if (username != null) {
            LoggedUser.initInstance(user.uid, user.photoURL ?? "", user.email!, username);
            await MongoDB.instance.initUser(user.uid);
            Navigator.pushNamedAndRemoveUntil(context, '/switch_page', (route) => false);
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        InsertUsernameScreen(user: user)));
          }
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      InsertUsernameScreen(user: user)));
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/switch_page', (route) => false);
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/sign_in_page', (route) => false);
    }
    return user;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.green, letterSpacing: 0.5),
      ),
    );
  }

  static Future<User?> signInWithGoogle({required BuildContext context, }) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    print(FirebaseAuth.instance.currentUser);

    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user!;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'The account already exists with a different credential',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error occurred using Google Sign In. Try again.',
          ),
        );
      }

      return user;
    }
  }

  static Future<User?> signInAnonymously() async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signInAnonymously().then((value) {
      user = value.user!;
    });
    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}