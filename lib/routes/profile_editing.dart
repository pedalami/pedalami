import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedala_mi/routes/profile_page.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ProfileEditing extends StatefulWidget {
  ProfileEditing({Key? key}) : super(key: key);

  @override
  _ProfileEditingState createState() => _ProfileEditingState();
}

class _ProfileEditingState extends State<ProfileEditing> {
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
                    // SizedBox(
                    //   width: 5 * SizeConfig.widthMultiplier!,
                    // ),
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
                              width: 3 * SizeConfig.widthMultiplier!,
                            ),
                          ],
                        )
                      ],
                    )
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
                            left: 10.0, top: 3 * SizeConfig.heightMultiplier!),
                        child:
                        Text(
                          nStringToNNString(user!.displayName),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("Change username"),
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightGreen)),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Padding (
                      padding: EdgeInsets.only(
                      left: 10, top: 3 * SizeConfig.heightMultiplier!),
                      child:
                        Text(
                        nStringToNNString(
                        nStringToNNString(user!.email)),
                        style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 2.5 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("Change email address"),
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightGreen)),
                        ),
                      ),
                      SizedBox(
                        height: 30 * SizeConfig.heightMultiplier!,
                      ),
                      Container(
                        height: 20 * SizeConfig.heightMultiplier!,
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
  String nStringToNNString(String? str) {
    return str ?? "";
  }
}
