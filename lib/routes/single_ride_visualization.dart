import 'package:flutter/material.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'ride_complete_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShowSingleRideHistoryPage extends StatefulWidget {
  final Ride ride;

  const ShowSingleRideHistoryPage({Key? key, required this.ride})
      : super(key: key);

  @override
  _ShowSingleRideHistoryPageState createState() =>
      _ShowSingleRideHistoryPageState();
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

class _ShowSingleRideHistoryPageState extends State<ShowSingleRideHistoryPage> {
  late CustomController controller;

  @override
  void initState() {
    controller = CustomController(
        initMapWithUserPosition: false,
        initPosition:
            widget.ride.path![(widget.ride.path!.length / 2).floor()]);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (ctx, orientation) {
          return Container(
            child: Stack(
              children: [
                OSMFlutter(
                  controller: controller,
                  onMapIsReady: (isReady) {
                    controller.drawRoad(
                        widget.ride.path!.first, widget.ride.path!.last,
                        intersectPoint: widget.ride.path!
                            .sublist(1, widget.ride.path!.length - 1),
                        roadType: RoadType.bike,
                        roadOption: RoadOption(
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
                                  screen: RideCompletePage(bonusPoints: '0',
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
