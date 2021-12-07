import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';

MongoDB instance = MongoDB.instance;

void main() {
  test('initUser testing', () async {
    instance.localDebug();
    assert(await instance.initUser("myid") == true);
  });

  test('record a ride testing', () async {
    instance.localDebug();
    GeoPoint gp = new GeoPoint(longitude: 1.0, latitude: 2.0);
    List<GeoPoint> gpl = [];
    gpl.add(gp);
    gpl.add(gp);
    gpl.add(gp);
    Ride ride = new Ride("15MkgTwMyOST77sinqjCzBhaPyE3", "first_test_ride",
        20.0, 0.1, null, "2021-12-03", 0.4, null, gpl);
    assert(await instance.recordRide(ride) != null);
    //assert(await instance.initUser("myid") == true);
  });

}

