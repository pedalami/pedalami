import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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

  void getLocationPermission() async {
    await Permission.locationAlways.request();
  }

  @override
  void initState() {
    super.initState();
    getLocationPermission();
    controller = CustomController(
      initMapWithUserPosition: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (ctx, orientation) {
        return Container(
          child: Stack(
            children: [
              OSMFlutter(
                controller: controller,
                onMapIsReady: (myLocation) {
                  controller.enableTracking();
                  controller.currentLocation();
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
                onGeoPointClicked: (geoPoint) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${geoPoint.toMap().toString()}",
                      ),
                      action: SnackBarAction(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                                    Duration(seconds: 15), (Timer t) async {
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
                                    controller.drawRoad(path.first, path.last,
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
                                  //TODO: Show dialog with the saved ride, stats, points earned etc...
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
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Unable to Save Ride"),
      content: Text(
          "We are unable to detect that you have moved since you started recording your ride"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
