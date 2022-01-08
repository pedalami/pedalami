import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/routes/events_page.dart';
import 'package:pedala_mi/routes/rewards_page.dart';
import 'package:pedala_mi/routes/teams_search.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'map_page.dart';
import 'profile_page.dart';
import 'teams_search.dart';
import 'events_page.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key? key}) : super(key: key);

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      navBarStyle: NavBarStyle.style9,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white
      ),
      screens: [
        MapPage(),
        ProfilePage(),
        TeamsSearchPage(),
        EventsPage(),
        RewardPage()
      ],
      items: [
        PersistentBottomNavBarItem(
          activeColorPrimary: Colors.green,
            icon: FaIcon(FontAwesomeIcons.map), title: 'Map'),
        PersistentBottomNavBarItem(
            activeColorPrimary: Colors.green,
            icon: FaIcon(FontAwesomeIcons.user), title: 'Profile'),
        PersistentBottomNavBarItem(
            activeColorPrimary: Colors.green,
            icon: FaIcon(FontAwesomeIcons.peopleArrows), title: 'Teams'),
        PersistentBottomNavBarItem(
            activeColorPrimary: Colors.green,
            icon: FaIcon(FontAwesomeIcons.star), title: 'Events'),
        PersistentBottomNavBarItem(
            activeColorPrimary: Colors.green,
            icon: FaIcon(FontAwesomeIcons.dollarSign), title: 'Rewards')
      ],
    );
  }
}
