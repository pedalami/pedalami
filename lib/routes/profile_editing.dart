import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/utils/get_image.dart';
import 'package:pedala_mi/utils/username_check.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ProfileEditing extends StatefulWidget {
  ProfileEditing({Key? key}) : super(key: key);

  @override
  _ProfileEditingState createState() => _ProfileEditingState();
}

class _ProfileEditingState extends State<ProfileEditing> {
  User? user = FirebaseAuth.instance.currentUser;
  bool check = false;
  final usernameController = TextEditingController();
  String username = LoggedUser.instance!.username;
  String imageUrl = LoggedUser.instance!.image.url;
  bool imgInserted = false;
  File? f;

  @override
  void initState() {
    setState(() {
      usernameController.value = usernameController.value.copyWith(text: username);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.green[600],
                height: 30 * SizeConfig.heightMultiplier!,
                child: Transform.translate(
                  offset: const Offset(0,-10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 11 * SizeConfig.heightMultiplier!,
                              width: 22 * SizeConfig.widthMultiplier!,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(imageUrl),
                                  )),
                            ),
                            SizedBox(
                              width: 5 * SizeConfig.widthMultiplier!,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  username,
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
                                          LoggedUser.instance!.mail,
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize:
                                                1.5 * SizeConfig.textMultiplier!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0,-30),
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
                                top: 3 * SizeConfig.heightMultiplier!,),
                            child: !imgInserted?ElevatedButton(
                                onPressed: () async {
                                  Map<Permission, PermissionStatus> statuses = await [
                                    Permission.camera,
                                    Permission.storage,
                                  ].request();
                                  _showPicker(context);
                                },
                                child: Text("Change profile picture"),
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all(
                                        Size(200, 35)),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.lightGreen),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0))))):CircularProgressIndicator(
                              color: Colors.lightGreen,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 15,
                                top: 3 * SizeConfig.heightMultiplier!,
                                right: 15.0),
                            child: TextField(
                              cursorColor: Colors.lightGreen,
                              decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                    color: CustomColors.silver,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: CustomColors.silver),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.lightGreen),
                                  ),
                                  hintText: "Insert new username",
                                  hintStyle:
                                      TextStyle(color: CustomColors.silver)),
                              controller: usernameController,
                              maxLength: 20,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 1 * SizeConfig.heightMultiplier!,),
                            child: ElevatedButton(
                              onPressed: () {
                                checkValue();
                              },
                              child: Text("Change username"),
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      Size(200, 35)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0))))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }

  void checkValue() async {
    setState(() {
      check = true;
    });
    await updateUsername(usernameController.text, context);
    setState(() {
      check = false;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () async {
                        if (await Permission.storage.isGranted) {
                          f = await getImageGallery();
                          if (f != null) {
                            setState(() {
                              imgInserted = true;
                            });
                            loadImageToFirebase(f!);
                          }
                        } else {
                          var storageAccessStatus =
                              await Permission.storage.status;
                          if (storageAccessStatus != PermissionStatus.granted) {
                            //here
                            var status = await Permission.storage.request();
                            if (status == PermissionStatus.permanentlyDenied) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "To use this funcion, please allow access to storage in settings.",),
                                action: SnackBarAction(
                                  label: "Settings",
                                  textColor: Colors.lightGreen,
                                  onPressed: () {
                                    openAppSettings();
                                  },
                                ),
                              ));
                            }
                          } else {
                            Permission.storage.request();
                          }
                        }
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      if (await Permission.camera.isGranted) {
                        f = await getImageCamera();
                        if (f != null) {
                          setState(() {
                            imgInserted = true;
                          });
                          loadImageToFirebase(f!);
                        }
                      } else {
                        var cameraAccessStatus = await Permission.camera.status;
                        if (cameraAccessStatus != PermissionStatus.granted) {
                          var status = await Permission.camera.request();
                          if (status == PermissionStatus.permanentlyDenied) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                "To use this funcion, please allow access to camera in settings.",),
                              action: SnackBarAction(
                                label: "Settings",
                                textColor: Colors.lightGreen,
                                onPressed: () {
                                  openAppSettings();
                                },
                              ),
                            ));
                          }
                        } else {
                          Permission.camera.request();
                        }
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void loadImageToFirebase(File? image) async {
    var uuid = Uuid().v4();
    try
    {
      if (image != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref();
        Reference imageRef = storageRef.child(uuid.toString() + ".jpg");
        await imageRef.putFile(image);
        CollectionReference usersCollection = FirebaseFirestore.instance.collection("Users");
        String docID="";
        String urlFirebase="";
        await usersCollection
            .where("Mail", isEqualTo: user!.email)
            .get()
            .then((QuerySnapshot querySnapshot) async {
          docID=querySnapshot.docs[0].id;
          urlFirebase=querySnapshot.docs[0].get("Image");
        });
        await imageRef.getDownloadURL().then( (url) async {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(docID)
              .update({"Image": url})
              .then( (value) async{
            LoggedUser.instance!.changeProfileImage(url);
            await FirebaseStorage.instance.refFromURL(urlFirebase).delete();
            imageUrl=url;
            setState(() {

            });
          });
        });

      }
    }
    finally
    {
      imgInserted=false;
      setState(() {

      });
    }

  }

}
