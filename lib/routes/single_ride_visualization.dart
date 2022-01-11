import 'package:flutter/material.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart' as osm;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as p_osm;

import 'package:pedala_mi/models/ride.dart' as m_ride;
import 'package:pedala_mi/utils/mobile_library.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'ride_complete_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowSingleRideHistoryPage extends StatefulWidget {
  final m_ride.Ride ride;

  const ShowSingleRideHistoryPage({Key? key, required this.ride})
      : super(key: key);

  @override
  _ShowSingleRideHistoryPageState createState() =>
      _ShowSingleRideHistoryPageState();
}

class CustomController extends p_osm.MapController {
  CustomController({
    bool initMapWithUserPosition = true,
    osm.GeoPoint? initPosition,
    osm.BoundingBox? areaLimit = const osm.BoundingBox.world(),
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

class _ShowSingleRideHistoryPageState extends State<ShowSingleRideHistoryPage> {
  late CustomController controller;

  @override
  void initState() {
    controller = CustomController(
        initMapWithUserPosition: false,
        initPosition: osm.GeoPoint(
            longitude: widget
                .ride.path![(widget.ride.path!.length / 2).floor()].longitude,
            latitude: widget
                .ride.path![(widget.ride.path!.length / 2).floor()].latitude));
    // TODO: implement initState
    super.initState();
  }

  List<osm.GeoPoint> convertGeoList() {
    List<osm.GeoPoint> listToReturn = [];

    for (var point
        in widget.ride.path!.sublist(1, widget.ride.path!.length - 1)) {
      listToReturn.add(
          osm.GeoPoint(longitude: point.longitude, latitude: point.latitude));
    }
    return listToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (ctx, orientation) {
          return Container(
            child: Stack(
              children: [
                p_osm.OSMFlutter(
                  controller: controller,
                  onMapIsReady: (isReady) {
                    controller.drawRoad(
                        osm.GeoPoint(
                            latitude: widget.ride.path!.first.latitude,
                            longitude: widget.ride.path!.first.longitude),
                        osm.GeoPoint(
                            latitude: widget.ride.path!.last.latitude,
                            longitude: widget.ride.path!.last.longitude),
                        intersectPoint: convertGeoList(),
                        roadType: p_osm.RoadType.bike,
                        roadOption: p_osm.RoadOption(
                          roadWidth: 10,
                          roadColor: Colors.green,
                        ));
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
                          onPressed: () => ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar(),
                          label: "hide",
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                    bottom: MediaQuery.of(context).size.height / 8,
                    width: MediaQuery.of(context).size.width / 1,
                    child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(Size(
                                    MediaQuery.of(context).size.width / 3,
                                    MediaQuery.of(context).size.height / 15)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                            onPressed: () {
                              pushNewScreen(context,
                                  screen: RideCompletePage(
                                      bonusPoints: '0',
                                      finishedRide: widget.ride));
                            },
                            icon: FaIcon(FontAwesomeIcons.book),
                            label: Text('Stats')))),
              ],
            ),
          );
        },
      ),
    );
  }
}
