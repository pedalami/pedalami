import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/models/event.dart';
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
    var uid = 'TrMO2au4MgO4uFmKFmOgV2rVuwG3';
    var lid = LoggedUser.instance!.userId;
    bool res = await instance.initUser(uid);
    print(LoggedUser.instance!.badges);
    print(LoggedUser.instance!.teams);
    print(LoggedUser.instance!.joinedEvents);
    print("Num di rewards: " +
        LoggedUser.instance!.redeemedRewards!.length.toString());
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
    final bytes =
        File("/Users/vi/Downloads/badges/totKm1.png").readAsBytesSync();
    String base64Image = "data:image/png;base64," + base64Encode(bytes);
    print(base64Image);
  });

  test('record a ride testing', () async {
    instance.localDebug();
    GeoPoint gp = new GeoPoint(longitude: 1.0, latitude: 2.0);
    List<GeoPoint> gpl = [];
    gpl.add(gp);
    gpl.add(gp);
    gpl.add(gp);
    Ride ride = new Ride(LoggedUser.instance!.userId, "newDateTest", null, 20.0,
        0.1, null, DateTime.now(), 0.4, null, gpl);
    assert(await instance.recordRide(ride) != null);
  });

  test('ride history testing', () async {
    instance.localDebug();
    List<Ride>? response =
        await MongoDB.instance.getAllRidesFromUser(LoggedUser.instance!.userId);
    print(response);
    assert(response != null);
  });

  test('get list of available rewards', () async {
    instance.localDebug();
    List<Reward>? rewards = await instance.getRewards();
    assert(rewards != null);
    print(rewards!);
  });

  test('redeem a reward', () async {
    instance.localDebug();
    LoggedUser.instance!.points = 300;
    RedeemedReward? newReward =
        await instance.redeemReward('61b0ce42c08e1dcc4daa29ab');
    assert(newReward != null);
    print(newReward!);
  });

  test('getRewardsByUser testing', () async {
    instance.localDebug();
    List<RedeemedReward>? x =
        await instance.getAllRewardsFromUser("CO64i9QNqEewozGVxBfywjjwsFq2");
    print(x);
    assert(x != null);
  });

  test('getTeam testing', () async {
    instance.localDebug();
    Team? t = await instance.getTeam("61b7a6d7d13fcf04e9955329");
    print(t?.members ?? "Null team");
    assert(t != null);
  });


  test('create private team event testing', () async {
    instance.localDebug();
    String adminId = "wqYXryHv31anGdjr2AsjjijLH0y1"; //vince
    String hostTeamId = "61b64efb747c3add24055e25"; //teamvince
    String invitedTeamId = "61b7e246f34ee1e975875025"; //Lorenzo's team - adminId: bRyLXZg1VNQIAq4fSC1REbaXMhi1
    Event? e = await instance.createPrivateTeamEvent(
        adminId, hostTeamId, invitedTeamId,
        "private team event 2", "create private team event testing",
        DateTime.now(), DateTime.now().add(Duration(days: 4))
    );
    print(e?.id ?? "Null event");
    assert(e != null);
  });

  test('create public team event testing', () async {
    instance.localDebug();
    String adminId = "wqYXryHv31anGdjr2AsjjijLH0y1"; //vince
    String hostTeamId = "61b64efb747c3add24055e25"; //teamvince
    Event? e = await instance.proposePublicTeamEvent(
        adminId, hostTeamId,
        "Vince public event testing", "create public team event testing",
        DateTime.now(), DateTime.now().add(Duration(days: 1))
    );
    print(e?.id ?? "Null event");
    assert(e != null);
  });

  test('enroll to public event testing', () async {
    instance.localDebug();
    String eventId = "61d6cbaaabb678931acd381c";
    String adminId = "bRyLXZg1VNQIAq4fSC1REbaXMhi1"; //Lorenzo userId
    String teamId = "61b7e246f34ee1e975875025"; //"Lorenzo's team" id
    assert(await instance.enrollTeamToPublicEvent(eventId, adminId, teamId));
  });

  test('accept private team event invite testing', () async {
    instance.localDebug();
    String eventId = "61ce12b0a1e789d3bd01ab95";
    String adminId = "bRyLXZg1VNQIAq4fSC1REbaXMhi1"; //Lorenzo userId
    String teamId = "61b7e246f34ee1e975875025"; //"Lorenzo's team" id
    assert(await instance.acceptInvite(eventId, adminId, teamId));
  });

  test('reject private team event invite testing', () async {
    instance.localDebug();
    String eventId = "61d724a8ab1c282cdc6ad488";
    String adminId = "bRyLXZg1VNQIAq4fSC1REbaXMhi1"; //Lorenzo userId
    String teamId = "61b7e246f34ee1e975875025"; //"Lorenzo's team" id
    assert(await instance.rejectInvite(eventId, adminId, teamId));
  });

  test('send private team event invite testing', () async {
    instance.localDebug();
    String eventId = "61d724a8ab1c282cdc6ad488";
    String adminId = "wqYXryHv31anGdjr2AsjjijLH0y1"; //vince userId
    String hostTeamId = "61b64efb747c3add24055e25"; //teamvince
    String invitedTeamId = "61b7e246f34ee1e975875025"; //"Lorenzo's team" id
    assert(await instance.sendInvite(eventId, adminId, hostTeamId, invitedTeamId));
  });

  test('search event testing', () async {
    instance.localDebug();
    String teamId = "61b7e246f34ee1e975875025"; //Lorenzo's team -
    String adminId = "bRyLXZg1VNQIAq4fSC1REbaXMhi1"; //Lorenzo
    List<Event>? events = await instance.searchEvent("private", teamId, adminId);
    print(events);
    assert(events != null);
  });

  test('join event testing', () async {
    instance.localDebug();
    String eventId = "61d6cbaaabb678931acd381c";
    String userId = "bRyLXZg1VNQIAq4fSC1REbaXMhi1";
    String? teamId = "61b7e246f34ee1e975875025";
    assert(await instance.joinEvent(eventId, userId, teamId: teamId));
  });

  test('get joinable events testing', () async {
    instance.localDebug();
    String userId = "CO64i9QNqEewozGVxBfywjjwsFq2";
    List<Event>? events = await instance.getJoinableEvents(userId);
    print(events);
    /*print("Involved teams are:");
    events?.forEach((event) {
      if (!event.isIndividual()) {
        print(event.id);
        print(event.enrolledTeamsIds);
      }
    });*/
    assert(events != null);
  });
}
