import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/routes/create_team.dart';
import 'package:pedala_mi/routes/events_page.dart';
import 'package:pedala_mi/routes/profile_editing.dart';
import 'package:pedala_mi/routes/profile_page.dart';
import 'package:pedala_mi/routes/rewards_page.dart';
import 'package:pedala_mi/routes/sign_in.dart';
import 'package:pedala_mi/routes/sign_in_page.dart';
import 'package:pedala_mi/routes/splashscreen_page.dart';
import 'package:pedala_mi/routes/switching_page.dart';
import 'package:pedala_mi/routes/team_members.dart';
import 'package:pedala_mi/routes/teams_page.dart';
import 'package:pedala_mi/routes/teams_search.dart';
import 'package:pedala_mi/size_config.dart';
import 'routes/start_page.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(
        builder: (context, orientation) {
          SizeConfig().init(constraints, orientation);
          return MaterialApp(
            routes: {
              'signInScreen':(context)=>SignInScreen(),
              '/profile': (context) => ProfilePage(refreshBottomBar: (){},),
              '/edit': (context) => ProfileEditing(),
              '/start': (context) => StartPage(),
              '/sign_in': (context) => SignInPage(),
              '/sign_in_page': (context) => SignInScreen(),
              '/switch_page': (context) => SwitchPage(),
              //'/team_members': (context) => TeamMembers(),
              //'/current_team': (context) => TeamProfile(),
              '/events': (context) => EventsPage(),
              '/search_team': (context) => TeamsSearchPage(),
              '/create_team': (context) => TeamCreation(),
              'reward':(context)=>RewardPage()
            },
            home: SplashScreen(),

          );
        },
      );
    });
  }
}
