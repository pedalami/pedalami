import 'package:flutter/material.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class ShowSingleRideHistoryPage extends StatefulWidget {
  final List<GeoPoint> path;

  const ShowSingleRideHistoryPage({Key? key, required this.path})
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
        initPosition: widget.path[(widget.path.length / 2).floor()]);
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
                    controller.drawRoad(widget.path.first, widget.path.last,
                        intersectPoint:
                            widget.path.sublist(1, widget.path.length - 1),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
