import 'package:flutter/material.dart';



class WebDashBoard extends StatefulWidget {
  const WebDashBoard({Key? key}) : super(key: key);

  @override
  _WebDashBoardState createState() => _WebDashBoardState();
}

class _WebDashBoardState extends State<WebDashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HEJ"),
      ),
      body: Text("HEJ"),
    );
  }
}
