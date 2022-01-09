import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/ride_complete_page.dart';
import 'package:pedala_mi/utils/mobile_library.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:location/location.dart' as loc;
import 'package:pedala_mi/widget/custom_alert_dialog.dart';
import 'package:pedala_mi/services/external_api_service.dart';

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


class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();

}

class _MapPageState extends State<MapPage> with OSMMixinObserver, WidgetsBindingObserver {
  final MapController controller = MapController(initMapWithUserPosition: true);
  double totalElevation = 0;
  bool _isRecording = false;
  bool _hasPermission = false;
  bool _shouldInitialize = true;
  Color _currentButtonColor = Colors.green[400]!;
  Text _currentButtonText = Text("Start");
  FaIcon _currentButtonIcon = FaIcon(FontAwesomeIcons.play);
  List<GeoPoint> path = [];
  RoadInfo? _roadInfo;
  LoggedUser _miUser = LoggedUser.instance!;
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  List<double> elevations = [];
  OSMFlutter? map;

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      print("Ready");
      if (_shouldInitialize) {
        print("initialize");
        await controller.currentLocation();
        await controller.enableTracking();
        setState(() {
          _shouldInitialize = false;
        });
      }
      controller.setZoom(stepZoom: 10.0);
      //controller.zoomIn();
    }
  }

  @override
  Future<void> mapRestored() async {
    super.mapRestored();
    //print("Map restored");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    //controller.currentLocation();
    /*if (state == AppLifecycleState.inactive && !_isRecording) {
      await controller.disabledTracking();
    }
    if (state == AppLifecycleState.resumed) {
      await controller.enableTracking();
    }*/
    setState(() {
      _currentState = state;
    });
    super.didChangeAppLifecycleState(state);
  }

  void getLocationPermission() async {
    bool hasPermission = await Permission.locationAlways.request().isGranted;
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  void parseLocation(Location location) {
    if (path.last.latitude == location.latitude && path.last.longitude == location.longitude) {
      print("No need to save the current position");
    } else {
      if (_isRecording) {
        path.add(GeoPoint(latitude: location.latitude!, longitude: location.longitude!));
        double newAltitude = location.altitude!;
        if (newAltitude < elevations.last) {
          totalElevation = (totalElevation + (newAltitude - elevations.last));
          elevations.add(newAltitude);
        }
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addObserver(this);
    WidgetsBinding.instance?.addObserver(this);
    getLocationPermission();
    print("1");
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (map == null) {
      map = OSMFlutter(
        controller: controller,
        //onMapIsReady: mapIsReady,
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
        //key: widget.key,
        androidHotReloadSupport: true,
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
        showDefaultInfoWindow: false,
        //onLocationChanged: (myLocation) { print(myLocation); },
        onGeoPointClicked: (geoPoint) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${geoPoint.toMap().toString()}",
              ),
              action: SnackBarAction(
                onPressed: () =>
                    ScaffoldMessenger.of(context)
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
      );
    }
    Size size = MediaQuery.of(context).size;
    return _hasPermission ? Scaffold(
      body: OrientationBuilder(
        builder: (ctx, orientation) {
          return Container(
            child: Stack(
              children: [
                map!,
                Positioned(
                    bottom: size.height / 8,
                    width: size.width / 1,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: StatefulBuilder(
                          builder: (context, internalState) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                await controller.currentLocation();
                                await controller.enableTracking();
                                var myLocation = await controller.myLocation();
                                if (_isRecording == false) {
                                    showCurrentAirQuality(myLocation.latitude, myLocation.longitude);
                                    path.add(GeoPoint(latitude: myLocation.latitude, longitude: myLocation.longitude));
                                    elevations.add(0);
                                    _isRecording = true;
                                    BackgroundLocation.startLocationService();
                                    BackgroundLocation.getLocationUpdates((location) {
                                        controller.removeMarker(path.last);
                                        parseLocation(location);
                                        controller.addMarker(path.last,
                                            markerIcon: MarkerIcon(
                                                image: AssetImage('lib/assets/map_marker.png')
                                            ));
                                      });
                                    internalState(() {
                                      _currentButtonColor = Colors.redAccent;
                                      _currentButtonText = Text("Stop");
                                      _currentButtonIcon = FaIcon(FontAwesomeIcons.pause);
                                    });
                                } else {
                                  BackgroundLocation.stopLocationService();
                                  if (path.length < 3) {
                                    showAlertDialog(context);
                                  } else {
                                    Ride finishedRide = Ride(
                                        _miUser.userId,
                                        _miUser.username,
                                        null,
                                        _roadInfo!.duration,
                                        _roadInfo!.distance,
                                        null,
                                        DateTime.now(),
                                        totalElevation,
                                        null,
                                        path);
                                    Ride? response = await MongoDB.instance.recordRide(finishedRide);
                                    if (response != null) {
                                      showRideCompleteDialog(
                                          context, size, response);
                                    }
                                  }
                                  path.forEach((element) {
                                    controller.removeMarker(element);
                                  });
                                  internalState(() {
                                    _currentButtonText = Text("Start");
                                    _currentButtonColor = Colors.green[400]!;
                                    _currentButtonIcon = FaIcon(FontAwesomeIcons.play);
                                  });
                                  setState(() {
                                    path.clear();
                                    _isRecording = false;
                                  });
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
                //DEMO BUTTON
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
                              var fakePath = [
                                GeoPoint(
                                  latitude: 45.47706577107621,
                                  longitude: 9.225647327123237),
                                GeoPoint(
                                    latitude: 45.47911197529172,
                                    longitude: 9.22567362278855)
                              ];
                              var road = await controller.drawRoad(
                                  fakePath[0], fakePath[1],
                                  roadType: RoadType.bike,
                                  roadOption: RoadOption(
                                    roadWidth: 10,
                                    roadColor: Colors.green,
                              ));

                              Ride finishedRide = Ride(
                                  _miUser.userId,
                                  _miUser.username,
                                  null,
                                  road.duration,
                                  road.distance,
                                  null,
                                  DateTime.now(),
                                  totalElevation,
                                  null,
                                  fakePath
                              );

                              Ride? response = await MongoDB.instance
                                  .recordRide(finishedRide);

                              if (response != null) {
                                if (_miUser.rideHistory == null) {
                                  _miUser.rideHistory =
                                      List.empty(growable: true);
                                }
                                _miUser.rideHistory!.add(response);
                                //MongoDB.instance.initUser(_miUser.userId);
                                showRideCompleteDialog(context, size, response);
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
    ) : Container();
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

  showCurrentAirQuality(double? latitude, double? longitude) async {

    if(latitude != null && longitude != null) {
      print("AIR QUALITY: LAT & LONG" + latitude.toString() + "   " +
          longitude.toString());
      AirQuality instance = AirQuality.instance;
      int airQualityResultInt = await instance.getAirQualityIndexFromCoords(
          latitude, longitude);

      String airQualityResult = "Error";
      if(airQualityResultInt == 1){
        airQualityResult = "Good";
      }
      else if(airQualityResultInt == 2){
        airQualityResult = "Fair";
      }
      else if(airQualityResultInt == 3){
        airQualityResult = "Moderate";
      }
      else if(airQualityResultInt == 4){
        airQualityResult = "Poor";
      }
      else if(airQualityResultInt == 5){
        airQualityResult = "Very Poor";
      }

      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return buildCustomAlertOKDialog(context, "Air Quality",
              "Currently is: " + airQualityResult);
        },
      );
    }
    else{
      print("AIR QUALITY: LAT & LONG ARE NULL");
      }
  }

}
