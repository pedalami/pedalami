import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/ride_complete_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:location/location.dart' as loc;

class RideData {
  double? duration;
  double? length;
  String? userId;
  double? elevation = 5.0;
  String? rideName = "Bike Ride";
  String? date = "2021/11/29:21.15";

  RideData(double duration, double length, String userId, double elevation,
      String rideName, String date) {
    this.duration = duration;
    this.length = length;
    this.userId = userId;
    this.elevation = elevation;
    this.rideName = rideName;
    this.date = date;
  }
}

class CustomController extends MapController {
  CustomController({
    bool initMapWithUserPosition = true,
    GeoPoint? initPosition,
    BoundingBox? areaLimit = const BoundingBox.world(),
  })  : assert(
          initMapWithUserPosition || initPosition != null,
        ),
        super(
          initMapWithUserPosition: initMapWithUserPosition,
          initPosition: initPosition,
          areaLimit: areaLimit,
        );

  @override
  void init() {
    super.init();
  }
}

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CustomController controller;
  late GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<bool> zoomNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> visibilityZoomNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> advPickerNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> trackingNotifier = ValueNotifier(false);
  ValueNotifier<bool> showFab = ValueNotifier(true);
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  Timer? timer;
  Timer? _stateTick;
  double totalElevation = 0;
  int elapsedTime = 0;
  bool _isRecording = false;
  Color _currentButtonColor = Colors.green[400]!;
  Text _currentButtonText = Text("Start");
  FaIcon _currentButtonIcon = FaIcon(FontAwesomeIcons.play);
  double _rideDistance = 0;
  List<GeoPoint> path = [];
  RoadInfo? _roadInfo;
  User? user = FirebaseAuth.instance.currentUser;
  LoggedUser _miUser = LoggedUser.instance!;
  List<double>? elevations;
  late loc.Location location;
  late loc.LocationData _locationData;
  var currentRide = <List, String>{
    []: 'geopoints',
    []: 'elevation',
  };

  void getLocationPermission() async {
    await Permission.locationAlways.request();
  }

  @override
  void initState() {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    elevations = [];
    location = loc.Location();

    /*
    OLD. See the above new declaration of _miUser LoggedUser for reference.
    //TODO: Refactor this, shouldn't write this both in map page and profile page /Marcus
    firestore.CollectionReference usersCollection =
        firestore.FirebaseFirestore.instance.collection("Users");
    usersCollection
        .where("Mail", isEqualTo: user!.email)
        .get()
        .then((firestore.QuerySnapshot querySnapshot) async {
      //This setState serves no purpose, I leave it here if you want explanation why this is redundant /Marcus

      _miUser = new LoggedUser(
          querySnapshot.docs[0].id,
          querySnapshot.docs[0].get("Image"),
          querySnapshot.docs[0].get("Mail"),
          querySnapshot.docs[0].get("Username"),
      0.0); //Added because now the logged user should include the points
      //TODO - Comment added by Vincenzo:
      //This should not be there for sure. Every time the app is opened points are retrieved from MongoDB.
      //My suggestion is to have a single shared MiUser to use in the whole application.
    });
     */
    super.initState();

    getLocationPermission();
    controller = CustomController(initMapWithUserPosition: true);
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
    }
    //controller.listenerMapIsReady.removeListener(mapIsInitialized);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: OrientationBuilder(
        builder: (ctx, orientation) {
          return Container(
            child: Stack(
              children: [
                OSMFlutter(
                  controller: controller,
                  onMapIsReady: (isReady) {
                    controller.currentLocation();
                    controller.enableTracking();
                    controller.setZoom(stepZoom: 10.0);
                    controller.zoomIn();
                  },
                  mapIsLoading: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text("Map is Loading..")
                      ],
                    ),
                  ),
                  initZoom: 17,
                  minZoomLevel: 8,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(
                        Icons.location_history_rounded,
                        color: Colors.red,
                        size: 80,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                  showContributorBadgeForOSM: false,
                  //trackMyPosition: trackingNotifier.value,
                  showDefaultInfoWindow: false,
                  onLocationChanged: (myLocation) {
                    print(myLocation);
                  },
                  onGeoPointClicked: (geoPoint) async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${geoPoint.toMap().toString()}",
                        ),
                        action: SnackBarAction(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar(),
                          label: "hide",
                        ),
                      ),
                    );
                  },
                  road: Road(
                    startIcon: MarkerIcon(
                      icon: Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.brown,
                      ),
                    ),
                    roadColor: Colors.red,
                  ),
                  markerOption: MarkerOption(
                    defaultMarker: MarkerIcon(
                      icon: Icon(
                        Icons.home,
                        color: Colors.orange,
                        size: 64,
                      ),
                    ),
                    advancedPickerMarker: MarkerIcon(
                      icon: Icon(
                        Icons.location_searching,
                        color: Colors.green,
                        size: 64,
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: size.height / 8,
                    width: size.width / 1,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: StatefulBuilder(
                          builder: (context, internalState) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                await controller.enableTracking();
                                await controller.currentLocation();
                                if (_isRecording == false) {
                                  _locationData = await location.getLocation();
                                  elevations!.add(_locationData.altitude!);
                                  _isRecording = true;
                                  path.add(await controller.myLocation());
                                  controller.addMarker(path.last,
                                      markerIcon: MarkerIcon(
                                        image: AssetImage(
                                            'lib/assets/map_marker.png'),
                                      ));
                                  print(path);
                                  internalState(() {
                                    _currentButtonColor = Colors.redAccent;
                                    _currentButtonText = Text("Stop");
                                    _currentButtonIcon =
                                        FaIcon(FontAwesomeIcons.pause);
                                  });
                                  _stateTick = Timer.periodic(
                                      Duration(seconds: 3), (Timer t) async {
                                    //Ugly and repeating code, but was the only fix for the tracking bug
                                    await controller.enableTracking();
                                    await controller.currentLocation();
                                    await Future.delayed(Duration(seconds: 2));
                                    controller.removeMarker(path.last);
                                    var latestLocation =
                                        await controller.myLocation();
                                    if (path.last.latitude ==
                                            latestLocation.latitude &&
                                        path.last.latitude ==
                                            latestLocation.latitude) {
                                      print("No progress to save");
                                    } else {
                                      _locationData =
                                          await location.getLocation();
                                      double newAltitude =
                                          _locationData.altitude!;

                                      if (elevations!.last < newAltitude) {
                                        print(
                                            "Only downhill or no change in altitude, don't save");
                                      } else {
                                        elevations!.add(newAltitude);
                                        totalElevation = (totalElevation +
                                            (newAltitude - elevations!.last));
                                      }
                                      path.add(latestLocation);
                                    }
                                    if (path.length > 2) {
                                      _roadInfo = await controller.drawRoad(
                                          path.first, path.last,
                                          intersectPoint:
                                              path.sublist(1, path.length - 1),
                                          roadType: RoadType.bike,
                                          roadOption: RoadOption(
                                            roadWidth: 10,
                                            roadColor: Colors.green,
                                          ));
                                    }
                                    internalState(() {
                                      elapsedTime += 15;
                                    });
                                    controller.addMarker(path.last,
                                        markerIcon: MarkerIcon(
                                            image: AssetImage(
                                          'lib/assets/map_marker.png',
                                        )));
                                  });
                                } else {
                                  if (path.length < 3) {
                                    showAlertDialog(context);
                                  } else {
                                    Ride finishedRide = Ride(
                                        nStringToNNString(_miUser.userId),
                                        nStringToNNString(_miUser.username),
                                        null,
                                        _roadInfo!.duration,
                                        _roadInfo!.distance,
                                        null,
                                        DateTime.now(),
                                        totalElevation,
                                        500.0,
                                        path);

                                    Ride? response = await MongoDB.instance
                                        .recordRide(finishedRide);
                                    if (response != null) {
                                      if (_miUser.rideHistory == null) {
                                        _miUser.rideHistory = List.empty();
                                      }
                                      _miUser.rideHistory!.add(response);
                                      await MongoDB.instance.initUser(
                                          _miUser.userId);
                                      _miUser.notifyListeners();
                                      showRideCompleteDialog(
                                          context, size, response);
                                    }
                                    print(response!.rideId);
                                    await MongoDB.instance.initUser(_miUser.userId);
                                    _miUser.notifyListeners();
                                    showRideCompleteDialog(
                                        context, size, response);
                                  }
                                  path.forEach((element) {
                                    controller.removeMarker(element);
                                  });
                                  path.clear();
                                  _isRecording = false;
                                  internalState(() {
                                    _currentButtonText = Text("Start");
                                    _currentButtonColor = Colors.green[400]!;
                                    _currentButtonIcon =
                                        FaIcon(FontAwesomeIcons.play);
                                  });
                                  _stateTick!.cancel();
                                }
                              },
                              label: _currentButtonText,
                              icon: _currentButtonIcon,
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      Size(size.width / 2, size.height / 15)),
                                  backgroundColor: MaterialStateProperty.all(
                                      _currentButtonColor),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ))),
                            );
                          },
                        ))),
                Positioned(
                    bottom: size.height / 4,
                    width: size.width / 0.6,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: StatefulBuilder(builder: (context, internalState) {
                        return ElevatedButton.icon(
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                    Size(size.width / 3, size.height / 15)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.amber),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ))),
                            onPressed: () async {
                              var road = await controller.drawRoad(
                                  GeoPoint(
                                      latitude: 45.47706577107621,
                                      longitude: 9.225647327123237),
                                  GeoPoint(
                                      latitude: 45.47911197529172,
                                      longitude: 9.22567362278855),
                                  roadType: RoadType.bike,
                                  roadOption: RoadOption(
                                    roadWidth: 10,
                                    roadColor: Colors.green,
                                  ));

                              Ride finishedRide = Ride(
                                  nStringToNNString(_miUser.userId),
                                  nStringToNNString(_miUser.username),
                                  null,
                                  road.duration,
                                  road.distance,
                                  null,
                                  DateTime.now(),
                                  totalElevation,
                                  500.0, [
                                GeoPoint(
                                    latitude: 45.47706577107621,
                                    longitude: 9.225647327123237),
                                GeoPoint(
                                    latitude: 45.47911197529172,
                                    longitude: 9.22567362278855)
                              ]);


                              Ride? response = await MongoDB.instance
                                  .recordRide(finishedRide);

                              if (response != null) {
                                if(_miUser.rideHistory == null){
                                  _miUser.rideHistory = List.empty();
                                }
                                _miUser.rideHistory!.add(response);
          await MongoDB.instance.initUser(_miUser.userId);
          _miUser.notifyListeners();
          showRideCompleteDialog(
          context, size, response);
          //sleep(Duration(seconds:20));


                                /*MongoDB.instance.initUser(_miUser.userId);
                                //showRideCompleteDialog(context, size, response);
                                pushNewScreen(context,
                                    screen: RideCompletePage(
                                        finishedRide: response));
                                _miUser.notifyListeners();
                              setState(() {

                              });*/


                              }
                            },
                            icon: FaIcon(FontAwesomeIcons.bicycle),
                            label: Text("Demo"));
                      }),
                    ))
              ],
            ),
          );
        },
      ),
    );
  }

  showRideCompleteDialog(BuildContext context, Size size, Ride finishedRide) {
    //TODO: FIX THIS
    //Last minute fix, didn't have the time to go out and test this yet. Will make it look nicer with all the stats /Marcus

    pushNewScreen(context,
        screen: RideCompletePage(
          finishedRide: finishedRide,
        ));
  }

  showAlertDialog(BuildContext context) {
    final snackBar = SnackBar(
        elevation: 20.0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "No movement detect since ride started",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Unable to save the ride",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }
}
