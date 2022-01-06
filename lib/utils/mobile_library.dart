export 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:flutter/material.dart';
export 'package:pedala_mi/routes/event_ranking.dart';
export 'package:pedala_mi/routes/splashscreen_page.dart';
export 'package:pedala_mi/routes/team_members.dart';
export 'package:pedala_mi/routes/teams_page.dart';
export 'package:pedala_mi/size_config.dart';
export 'package:flutter/services.dart';
export 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:pedala_mi/routes/create_team.dart';
import 'package:pedala_mi/routes/events_page.dart';
import 'package:pedala_mi/routes/profile_editing.dart';
import 'package:pedala_mi/routes/profile_page.dart';
import 'package:pedala_mi/routes/rewards_page.dart';
import 'package:pedala_mi/routes/sign_in.dart';
import 'package:pedala_mi/routes/sign_in_page.dart';
import 'package:pedala_mi/routes/start_page.dart';
import 'package:pedala_mi/routes/switching_page.dart';
import 'package:pedala_mi/routes/teams_search.dart';
import 'package:pedala_mi/routes/web_dashboard.dart';
import 'package:pedala_mi/routes/splashscreen_page.dart';
import 'package:flutter/material.dart';

class Conditional {
  Future<void> initFireBase() async {
    await Firebase.initializeApp();
  }

  Widget startPage = SplashScreen();

  final routes = {
    'signInScreen': (context) => SignInScreen(),
    '/profile': (context) => ProfilePage(),
    '/edit': (context) => ProfileEditing(),
    '/start': (context) => StartPage(),
    '/sign_in': (context) => SignInPage(),
    '/sign_in_page': (context) => SignInScreen(),
    '/switch_page': (context) => SwitchPage(),
    '/splash_page': (context) => SplashScreen(),
    //'/team_members': (context) => TeamMembers(),
    //'/current_team': (context) => TeamProfile(),
    '/events': (context) => EventsPage(),
    '/search_team': (context) => TeamsSearchPage(),
    '/create_team': (context) => TeamCreation(),
    'reward': (context) => RewardPage(),
    '/web_dashboard': (context) => WebDashBoard(),
  };
}
