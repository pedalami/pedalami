import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/routes/profile_page.dart';
import 'package:pedala_mi/routes/sign_in.dart';
import 'routes/start_page.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget  build(BuildContext  context) {
    return MaterialApp(
      routes: {
        '/profile': (context) => ProfilePage(),
        '/start': (context) => StartPage(),
        '/sign_in': (context) => SignInPage(),
      },
      home: StartPage(),
    );
  }
}