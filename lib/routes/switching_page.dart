import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/routes/create_team.dart';
import 'package:pedala_mi/routes/teams_search.dart';
import 'package:pedala_mi/routes/team_members.dart';
import 'package:pedala_mi/routes/events_page.dart';
import 'package:pedala_mi/routes/teams_page.dart';

import 'map_page.dart';
import 'profile_page.dart';
import 'teams_search.dart';
import 'team_members.dart';
import 'create_team.dart';
import 'events_page.dart';
import 'teams_page.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key? key}) : super(key: key);

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  List<Widget> pages = [MapPage(), ProfilePage(), TeamsSearchPage(), TeamMembers(), TeamCreation(), EventsPage(), TeamProfile()];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user), label: 'Profile'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.peopleArrows), label: 'Teams'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
      body: pages[_selectedIndex],
    );
  }
}
