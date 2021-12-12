import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';

MongoDB instance = MongoDB.instance;

void main() {
  test('initUser testing', () async {
    instance.localDebug();
    var uid ='15MkgTwMyOST77sinqjCzBhaPyE3';
    var lid = LoggedUser.instance!.userId;
    bool res = await instance.initUser(uid);
    print(LoggedUser.instance!.badges);
    print(LoggedUser.instance!.teams);
    print(LoggedUser.instance!.redeemedRewards);
    assert(res == true);
  });

  test('int testing', () async {
    print(double.parse("3").round());
    print("ab".split(',').last);
  });

  test('date testing', () async {
    print(MongoDB.formatDate(DateTime.now()));
    print(MongoDB.parseDate("2021-12-03T00:00:00.000Z"));
  });

  test('img testing', () async {
    final bytes = File("/Users/vi/Downloads/badges/totKm1.png").readAsBytesSync();
    String base64Image = "data:image/png;base64,"+base64Encode(bytes);
    print(base64Image);
  });



  test('record a ride testing', () async {
    instance.localDebug();
    GeoPoint gp = new GeoPoint(longitude: 1.0, latitude: 2.0);
    List<GeoPoint> gpl = [];
    gpl.add(gp);
    gpl.add(gp);
    gpl.add(gp);
    Ride ride = new Ride(LoggedUser.instance!.userId, "newDateTest", null,
        20.0, 0.1, null, DateTime.now(), 0.4, null, gpl);
    assert(await instance.recordRide(ride) != null);
  });

  test('ride history testing', () async {
    instance.localDebug();
    List<Ride>? response = await MongoDB.instance.getAllRidesFromUser(LoggedUser.instance!.userId);
    print(response);
    assert(response != null);
  });


  test('get list of available rewards', () async {
    instance.localDebug();
    List<Reward>? rewards = await instance.getRewards();
    assert (rewards != null);
    print(rewards!);
  });

  test('redeem a reward', () async {
    instance.localDebug();
    RedeemedReward? newReward = await instance.redeemReward(
        '61b0ce42c08e1dcc4daa29ab');
    assert (newReward != null);
    print(newReward!);
  });

  test('getRewardsByUser testing', () async {
    instance.localDebug();
    assert(await instance.getAllRewardsFromUser("yTi9ZmJbK4Sy4yykwRvrDAcCFPB3") != null);
  });

  test('getTeam testing', () async {
    instance.localDebug();
    Team? t = await instance.getTeam("61af228ca2719ca673109a22");
    print(t?.members ?? "Null team");
    assert(t != null);
  });

}

