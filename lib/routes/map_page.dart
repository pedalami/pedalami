import 'package:background_location/background_location.dart';
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

extension LocationDataExt on loc.LocationData {
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude: this.latitude!, longitude: this.longitude!);
  }

  Location toBGLocation() {
    return Location(
        longitude: longitude,
        latitude: latitude,
        altitude: altitude,
        accuracy: accuracy,
        bearing: null,
        speed: speed,
        time: time,
        isMock: isMock);
  }
}

extension LocationExt on Location {
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude: this.latitude!, longitude: this.longitude!);
  }
}

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with OSMMixinObserver, WidgetsBindingObserver {
  final MapController controller = MapController(initMapWithUserPosition: true);
  double totalElevation = 0;
  bool _hasPermissions = false;
  bool _isRecording = false;
  bool _shouldInitialize = true;
  Color _currentButtonColor = Colors.green[400]!;
  Text _currentButtonText = Text("Start");
  FaIcon _currentButtonIcon = FaIcon(FontAwesomeIcons.play);
  List<GeoPoint> path = [];
  RoadInfo? _roadInfo;
  LoggedUser _miUser = LoggedUser.instance!;
  List<double> elevations = [];
  OSMFlutter? map;
  Location? currentLocation;
  Stopwatch _stopwatch = Stopwatch();

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      print("Map ready");
      if (_shouldInitialize) {
        BackgroundLocation.startLocationService(distanceFilter: 4.0);
        currentLocation =
            (await loc.Location.instance.getLocation()).toBGLocation();
        controller.changeLocation(currentLocation!.toGeoPoint());
        BackgroundLocation.getLocationUpdates((location) async {
          controller.removeMarker(currentLocation!.toGeoPoint());
          currentLocation = location;
          controller.changeLocation(location.toGeoPoint());
          if (_isRecording) {
            controller.removeMarker(path.last);
            parseLocation(location);
            controller.addMarker(path.last,
                markerIcon:
                    MarkerIcon(image: AssetImage('lib/assets/map_marker.png')));
            if (path.length > 2) {
              controller.removeLastRoad();
              _roadInfo = await controller.drawRoad(path.first, path.last,
                  intersectPoint: path.sublist(1, path.length - 1),
                  roadType: RoadType.bike,
                  roadOption: RoadOption(
                    roadWidth: 10,
                    roadColor: Colors.green,
                  ));
            }
          }
          // setState(() {});
        });
        setState(() {
          _shouldInitialize = false;
        });
      }
      controller.setZoom(stepZoom: 10.0);
      //controller.zoomIn();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Permission.locationAlways.isGranted)
        setState(() {
          _hasPermissions = true;
        });
      else
        setState(() {
          _hasPermissions = false;
        });
    }
    super.didChangeAppLifecycleState(state);
  }

  void getLocationPermission() async {
    var status = Permission.locationWhenInUse.request();
    if (await status.isGranted) {
      var status = Permission.locationAlways.request();
      if (await status.isGranted)
        setState(() {
          _hasPermissions = true;
        });
    }
  }

  void parseLocation(Location location) {
    if (path.last.latitude == location.latitude &&
        path.last.longitude == location.longitude) {
      print("No need to save the current position");
    } else {
      if (_isRecording) {
        path.add(GeoPoint(
            latitude: location.latitude!, longitude: location.longitude!));
        double newAltitude = location.altitude!;
        if (newAltitude > elevations.last) {
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
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    controller.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (map == null && _hasPermissions) {
      map = OSMFlutter(
        controller: controller,
        mapIsLoading: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [CircularProgressIndicator(), Text("Map is Loading..")],
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
              size: 80,
              color: Colors.brown,
            ),
          ),
          roadColor: Colors.red,
        ),
        markerOption: MarkerOption(
          defaultMarker: MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 80,
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
    return _hasPermissions
        ? Scaffold(
            body: OrientationBuilder(
              builder: (ctx, orientation) {
                return Container(
                  child: Stack(
                    children: [
                      map!,
                      Positioned(
                          bottom: size.height / 13,
                          width: size.width / 1,
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: StatefulBuilder(
                                builder: (context, internalState) {
                                  return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Spacer(),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            if (!_isRecording) {
                                              if (currentLocation != null) {
                                                showCurrentAirQuality(
                                                    currentLocation!.latitude,
                                                    currentLocation!.longitude);
                                                path.add(currentLocation!
                                                    .toGeoPoint());
                                                elevations.add(
                                                    currentLocation!.altitude!);
                                                controller.addMarker(
                                                    currentLocation!
                                                        .toGeoPoint(),
                                                    markerIcon: MarkerIcon(
                                                        image: AssetImage(
                                                            'lib/assets/map_marker.png')));
                                                _isRecording = true;
                                                _stopwatch.start();
                                                internalState(() {
                                                  _currentButtonColor =
                                                      Colors.redAccent;
                                                  _currentButtonText =
                                                      Text("Stop");
                                                  _currentButtonIcon = FaIcon(
                                                      FontAwesomeIcons.pause);
                                                });
                                                setState(() {});
                                              } else {
                                                showAlertDialog(context,
                                                    "Current location not available yet");
                                              }
                                            } else {
                                              //BackgroundLocation.stopLocationService();
                                              var durationInSeconds = _stopwatch
                                                  .elapsed.inSeconds
                                                  .ceilToDouble();
                                              _stopwatch.stop();
                                              _stopwatch.reset();
                                              if (path.length < 3) {
                                                showAlertDialog(context,
                                                    "No movement detect since ride started\nNo ride will be saved");
                                              } else {
                                                Ride finishedRide = Ride(
                                                    _miUser.userId,
                                                    _miUser.username,
                                                    null,
                                                    durationInSeconds,
                                                    _roadInfo!.distance,
                                                    null,
                                                    DateTime.now(),
                                                    totalElevation,
                                                    null,
                                                    path);
                                                var response = await MongoDB
                                                    .instance
                                                    .recordRidePassingWeather(
                                                        finishedRide,
                                                        await getWeatherId(
                                                            currentLocation
                                                                ?.latitude!,
                                                            currentLocation
                                                                ?.longitude));
                                                if (response != null &&
                                                    response.item1 != null) {
                                                  showRideCompleteDialog(
                                                      context,
                                                      size,
                                                      response.item1!,
                                                      response.item2);
                                                }
                                              }
                                              path.forEach((element) {
                                                controller
                                                    .removeMarker(element);
                                              });
                                              internalState(() {
                                                _currentButtonText =
                                                    Text("Start");
                                                _currentButtonColor =
                                                    Colors.green[400]!;
                                                _currentButtonIcon = FaIcon(
                                                    FontAwesomeIcons.play);
                                              });
                                              setState(() {
                                                controller.removeLastRoad();
                                                controller.removeAllShapes();
                                                path.clear();
                                                _isRecording = false;
                                              });
                                            }
                                          },
                                          label: _currentButtonText,
                                          icon: _currentButtonIcon,
                                          style: ButtonStyle(
                                              fixedSize:
                                                  MaterialStateProperty.all(
                                                      Size(size.width / 2.5,
                                                          size.height / 15)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      _currentButtonColor),
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ))),
                                        ),
                                        Spacer(),
                                        //SizedBox(width: size.width/5),
                                        ElevatedButton.icon(
                                            style: ButtonStyle(
                                                fixedSize:
                                                    MaterialStateProperty.all(
                                                        Size(size.width / 2.5,
                                                            size.height / 15)),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.amber),
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                ))),
                                            onPressed: () async {
                                              var fakePath = [
                                                GeoPoint(
                                                    latitude: 45.47706577107621,
                                                    longitude:
                                                        9.225647327123237),
                                                GeoPoint(
                                                    latitude: 45.47911197529172,
                                                    longitude: 9.22567362278855)
                                              ];
                                              var road =
                                                  await controller.drawRoad(
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
                                                  fakePath);

                                              var response = await MongoDB
                                                  .instance
                                                  .recordRidePassingWeather(
                                                      finishedRide,
                                                      await getWeatherId(
                                                          45.47706577107621,
                                                          9.225647327123237));

                                              if (response != null &&
                                                  response.item1 != null) {
                                                if (_miUser.rideHistory ==
                                                    null) {
                                                  _miUser.rideHistory =
                                                      List.empty(
                                                          growable: true);
                                                }
                                                _miUser.rideHistory!
                                                    .add(response.item1!);
                                                MongoDB.instance
                                                    .initUser(_miUser.userId);
                                                //_miUser.notifyListeners();
                                                showRideCompleteDialog(
                                                    context,
                                                    size,
                                                    response.item1!,
                                                    response.item2);
                                              }
                                            },
                                            icon: FaIcon(
                                                FontAwesomeIcons.bicycle),
                                            label: Text("Demo")),
                                        Spacer()
                                      ]);
                                },
                              ))),
                    ],
                  ),
                );
              },
            ),
          )
        : Container();
  }

  showRideCompleteDialog(
      BuildContext context, Size size, Ride finishedRide, String bonusPoints) {
    pushNewScreen(context,
        screen: RideCompletePage(
            finishedRide: finishedRide, bonusPoints: bonusPoints));
  }

  showAlertDialog(BuildContext context, String text) {
    final snackBar = SnackBar(
        elevation: 25.0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showCurrentAirQuality(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      print("AIR QUALITY: LAT & LONG " +
          latitude.toString() +
          "   " +
          longitude.toString());
      AirQuality instance = AirQuality.instance;
      int airQualityResultInt =
          await instance.getAirQualityIndexFromCoords(latitude, longitude);

      String airQualityResult = "Error";
      if (airQualityResultInt == 1) {
        airQualityResult = "Good";
      } else if (airQualityResultInt == 2) {
        airQualityResult = "Fair";
      } else if (airQualityResultInt == 3) {
        airQualityResult = "Moderate";
      } else if (airQualityResultInt == 4) {
        airQualityResult = "Poor";
      } else if (airQualityResultInt == 5) {
        airQualityResult = "Very Poor";
      }

      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return buildCustomAlertOKDialog(
              context, "Air Quality", "Currently is: " + airQualityResult);
        },
      );
    } else {
      print("AIR QUALITY: LAT & LONG ARE NULL");
    }
  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }

  Future<int> getWeatherId(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      Weather instance = Weather.instance;
      int weatherId = await instance.getWeatherFromCoords(latitude, longitude);

      print("The WEATHER IS " + weatherId.toString());
      return weatherId;
    } else {
      print("Weather: LAT & LONG ARE NULL");
      return -1;
    }
  }
}
