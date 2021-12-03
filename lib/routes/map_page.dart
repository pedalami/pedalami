import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/routes/ride_complete_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class RideData {
  double? duration;
  double? length;
  String? user_id;
  double? elevation = 5.0;
  String? ride_name = "Bike Ride";
  String? date = "2021/11/29:21.15";

  RideData(double duration, double length, User user, double elevation,
      String ride_name, String date) {
    this.duration = duration;
    this.length = length;
    this.user_id = user.uid;
    this.elevation = elevation;
    this.ride_name = ride_name;
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
  int elapsedTime = 0;
  bool _isRecording = false;
  Color _currentButtonColor = Colors.green[400]!;
  Text _currentButtonText = Text("Start");
  FaIcon _currentButtonIcon = FaIcon(FontAwesomeIcons.play);
  double _rideDistance = 0;
  List<GeoPoint> path = [];
  RoadInfo? _roadInfo;

  void getLocationPermission() async {
    await Permission.locationAlways.request();
  }

  void onUpd(GeoPoint newLoc) {
    print("Heyyy");
  }

  @override
  void initState() {
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
                                    showRideCompleteDialog(
                                        context, size, _roadInfo!);
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
              ],
            ),
          );
        },
      ),
    );
  }

  showRideCompleteDialog(BuildContext context, Size size, RoadInfo roadInfo) {
    //TODO: FIX THIS
    //Last minute fix, didn't have the time to go out and test this yet. Will make it look nicer with all the stats /Marcus


    pushNewScreen(context, screen: RideCompletePage());


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
        SizedBox(height: 10,),
        Text(
          "Unable to save the ride",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ));
    print("HEJ");
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
