import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/username_insert_page.dart';
import 'package:pedala_mi/services/authentication.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pedala_mi/services/web_authentication.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.green),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(CustomColors.green),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                if(!kIsWeb)
                  {
                    setState(() {
                      _isSigningIn = true;
                    });
                    User? user =
                    await Authentication.signInWithGoogle(context: context);
                    setState(() {
                      _isSigningIn = false;
                    });
                    if (user != null) {
                      print(user.displayName);
                      CollectionReference usersCollection = FirebaseFirestore.instance.collection("Users");
                      QuerySnapshot querySnapshot = await usersCollection
                          .where("Mail", isEqualTo: user.email)
                          .get();
                      if (querySnapshot.docs.isNotEmpty) {
                        String? username = querySnapshot.docs[0].get("Username");

                        if (username != null) {
                          LoggedUser.initInstance(user.uid, user.photoURL ?? "", user.email!, username);
                          await MongoDB.instance.initUser(user.uid);



                          Navigator.pushNamedAndRemoveUntil(
                              context, '/switch_page', (route) => false);
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
                    }

                    setState(() {
                      _isSigningIn = false;
                    });
                  }
                else
                  {
                    setState(() {
                      _isSigningIn = true;
                    });
                    await webSignInWithGoogle(context: context);
                    setState(() {
                      _isSigningIn = false;
                    });
                  }

              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("lib/assets/google_logo.png"),
                      height: 35.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
