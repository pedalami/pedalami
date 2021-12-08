import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';

MongoDB instance = MongoDB.instance;

void main() {
  test('initUser testing', () async {
    instance.localDebug();
    bool res = await instance.initUser("yTi9ZmJbK4Sy4yykwRvrDAcCFPB3");
    print(LoggedUser.instance!.badges);
    print(LoggedUser.instance!.teams);
    assert(res == true);
  });

  test('int testing', () async {
    print(double.parse("3").round());
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
  });

  test('get list of available rewards', () async{
    instance.localDebug();
    List<Reward>? rewards = await instance.getRewards();
    assert (rewards != null);
    print(rewards!);
  });

  test('redeem a reward', () async{
    instance.localDebug();
    RedeemedReward? newReward = await instance.redeemReward('61b0ce42c08e1dcc4daa29ab');
    assert (newReward != null);
    print(newReward!);
  test('getRewardsByUser testing', () async {
    instance.localDebug();
    assert(await instance.getAllRewardsFromUser("yTi9ZmJbK4Sy4yykwRvrDAcCFPB3") != null);
  });

}

