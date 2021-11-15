import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          color: Colors.green[600],
          height: 40 * SizeConfig.heightMultiplier!,
          child: Padding(
            padding: EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                top: 10 * SizeConfig.heightMultiplier!),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: 11 * SizeConfig.heightMultiplier!,
                      width: 22 * SizeConfig.widthMultiplier!,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                NetworkImage(nStringToNNString(user!.photoURL)),
                          )),
                    ),
                    SizedBox(
                      width: 5 * SizeConfig.widthMultiplier!,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          nStringToNNString(user!.displayName),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 3 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 1 * SizeConfig.heightMultiplier!,
                        ),
                        Row(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  nStringToNNString(
                                      nStringToNNString(user!.email)),
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 1.5 * SizeConfig.textMultiplier!,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 7 * SizeConfig.widthMultiplier!,
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 3 * SizeConfig.heightMultiplier!,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "500",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 3 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Total KM",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 1.9 * SizeConfig.textMultiplier!,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "28",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 3 * SizeConfig.textMultiplier!,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Rewards",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 1.9 * SizeConfig.textMultiplier!,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/edit");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "EDIT PROFILE",
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 1.8 * SizeConfig.textMultiplier!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 35 * SizeConfig.heightMultiplier!),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  )),
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Current Team",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    "https://novaanime.org/wp-content/uploads/2021/08/one-punch-man-filler-list.jpeg",
                                    height: 20.0 * SizeConfig.heightMultiplier!,
                                    width: 50.0 * SizeConfig.widthMultiplier!,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        "Team Awesome",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )))
                            ],
                          ),
                          SizedBox(
                            width: 7.0 * SizeConfig.widthMultiplier!,
                          ),
                          Container(
                            width: 32.0 * SizeConfig.widthMultiplier!,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              label: Text("Change Team"),
                              icon: FaIcon(FontAwesomeIcons.userCog),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.green[400]),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.green)))),
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 30.0, top: 3 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Badges",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      SizedBox(
                        height: 3 * SizeConfig.heightMultiplier!,
                      ),
                      Container(
                        height: 20 * SizeConfig.heightMultiplier!,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            displayBadge(1),
                            displayBadge(1),
                            displayBadge(1),
                            displayBadge(1),
                            displayBadge(1),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget displayBadge(badgeID) {
    //If you want to be able to click on a badge for more information you can wrap all this in GestureDetector and a Hero widget to another page

    return Padding(
      padding: EdgeInsets.all(9),
      child: Container(
        height: 20.0 * SizeConfig.heightMultiplier!,
        width: 30.0 * SizeConfig.widthMultiplier!,
        child: Stack(
          children: [
            Image.network(
              "https://thumbs.dreamstime.com/b/gold-badge-5392868.jpg",
            ),
            Positioned.fill(
                child: Align(
              child: Text(
                "Badge info here",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.bottomCenter,
            )),
          ],
        ),
      ),
    );
  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }
}
