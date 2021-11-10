import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'map_page.dart';
import 'profile_page.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key? key}) : super(key: key);

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  List<Widget> pages = [MapPage(), ProfilePage()];
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
      body: pages[_selectedIndex],
    );
  }
}
