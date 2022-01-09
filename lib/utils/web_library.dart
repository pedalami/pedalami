export 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:flutter/material.dart';
export 'package:pedala_mi/routes/splashscreen_page.dart';


export 'package:pedala_mi/size_config.dart';
export 'package:flutter/services.dart';
export 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:pedala_mi/routes/sign_in.dart';
import 'package:pedala_mi/routes/sign_in_page.dart';
import 'package:pedala_mi/routes/start_page.dart';
import 'package:pedala_mi/routes/web_dashboard.dart';
import 'package:flutter/material.dart';

class Conditional {

  Future<void> initFireBase() async {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD9jCXLzUOxSsYMuLRgEw5elaqSdkPXb3M",
            authDomain: "pedala-mi.firebaseapp.com",
            projectId: "pedala-mi",
            storageBucket: "pedala-mi.appspot.com",
            messagingSenderId: "215517273270",
            appId: "1:215517273270:web:27cc8bffe4902628329a17"));
  }


  Widget startPage = SignInScreen();

  final routes = {
    '/start': (context) => StartPage(),
    '/sign_in': (context) => SignInPage(),
    '/sign_in_page': (context) => SignInScreen(),
    '/web_dashboard': (context) => WebDashBoard(),
  };
}
