import 'package:flutter/material.dart';

class RideCompletePage extends StatelessWidget {
  const RideCompletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Results",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                decoration: TextDecoration.underline),
          )),
          SizedBox(
            height: 70,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Time: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 100,
                ),
                Container(
                  child: Text(
                    "1.30 h",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Distance: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 100,
                ),
                Container(
                  child: Text(
                    "22.5 km",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "AVG Speed:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 100,
                ),
                Container(
                  child: Text(
                    "15 km/h",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Road Slope: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 100,
                ),

                Container(
                  child: Text(
                    "0.5%",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            height: 150,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              color: Colors.green[200],
              borderRadius: BorderRadius.all(Radius.circular(18.0))
            ),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Points Earned",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "500",
                  style: TextStyle(
                      fontSize: 60,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
