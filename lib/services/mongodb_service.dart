import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pedala_mi/models/badge.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/statistics.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:tuple/tuple.dart';

class MongoDB {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final MongoDB instance = new MongoDB();

  http.Client _serverClient = http.Client();
  String baseUri = "https://pedalami.herokuapp.com";
  static var _dateFormatter = DateFormat("yyyy-MM-ddTHH:mm:ss");

  Map<String, String> _headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  //Use to convert Dart DateTime object to a string whose format matches the one of the backend
  //returns the date in the following UTC format: 2021-12-03T03:30:40.000Z
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date.toUtc()) + ".000Z";
  }

  //Use to convert a string matching the database date format to Dart DateTime.
  //Note that the string must have the following UTC format: 2021-12-03T03:30:40.000Z
  static DateTime parseDate(String dateStr) {
    return _dateFormatter.parse(dateStr, true).toLocal();
  }

  void localDebug() {
    baseUri = "http://localhost:8000";
    LoggedUser.initInstance('testUser', 'imageUrl', 'mail', 'testUser');
  }

  //Returns true if everything went fine, false otherwise
  Future<bool> initUser(String userId) async {
    var url = Uri.parse(baseUri + '/users/initUser');
    var response = await _serverClient.post(url,
        headers: _headers, body: json.encode({'userId': userId}));
    if (response.statusCode == 200) {
      try {
        var decodedBody = json.decode(response.body);
        print("Received events json from the initUser");
        print(decodedBody["joinedEvents"]);
        var points = double.parse(decodedBody["points"].toString());
        Statistics stats = Statistics.fromJson(decodedBody["statistics"]);
        List<Team> teamList = decodedBody["teams"]
            ?.map<Team>((team) => Team.fromJson(team))
            .toList() ?? [];
        List<Badge> badgeList = decodedBody["badges"]
            ?.map<Badge>((badge) => Badge.fromJson(badge))
            .toList() ?? [];
        List<RedeemedReward> rewardsList = decodedBody["rewards"]
            ?.map<RedeemedReward>((reward) => RedeemedReward.fromJson(reward))
            .toList() ?? [];
        List<Event> eventsList = decodedBody["joinedEvents"]
            ?.map<Event>((event) => Event.fromJson(event))
            .toList() ?? [];
        LoggedUser.completeInstance(
            points, teamList, stats, badgeList, rewardsList, eventsList);
      } catch (ex, st) {
        print("The following exception occurred in the initUser:\n");
        print(ex);
        print(st);
        return false;
      }
      return true;
    } else
      return false;
  }

  //Returns from Firebase the username of a user with id = userId
  Future<String> getUsername(String userId) async {
    QuerySnapshot querySnapshot = await (FirebaseFirestore.instance
        .collection("Users")
        .where("userId", isEqualTo: userId)
        .get());
    return querySnapshot.docs.first.get("Username");
  }



  //TEAMS

  //Returns the team_id if everything went fine
  //Returns null in case of error
  Future<Team?> createTeam(String adminId, String name, String? description) async {
    var url = Uri.parse(baseUri + '/teams/create');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode(
            {'adminId': adminId, 'name': name, 'description': description}));
    if (response.statusCode == 200 && json.decode(response.body)["teamId"] != null) {
      return new Team(json.decode(response.body)["teamId"], adminId, name, description, [adminId], null);
    } else
      return null;
  }

  //Returns an array of the teams with the name matching the query if everything went fine
  //Returns null in case of error
  Future<List<Team>?> searchTeam(String name) async {
    var url = Uri.parse(baseUri + '/teams/search')
        .replace(queryParameters: {'name': name});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Team> teamList =
          decodedBody.map((team) => Team.fromJson(team)).toList();
      return teamList;
    } else
      return null;
  }

  //Returns true if everything went fine, false otherwise
  Future<bool> joinTeam(String teamId, String userId) async {
    var url = Uri.parse(baseUri + '/teams/join');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'userId': userId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns true if everything went fine, false otherwise
  Future<Tuple2<bool, String>> leaveTeam(String teamId, String userId) async {
    var url = Uri.parse(baseUri + '/teams/leave');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'userId': userId}));
    var returnTuple = Tuple2<bool, String>(
        response.statusCode == 200, response.body.toString());
    return returnTuple;
  }

  //Given the id of a Team, it returns the entire team
  Future<Team?> getTeam(String teamId) async {
    var url = Uri.parse(baseUri + '/teams/getTeam')
        .replace(queryParameters: {'teamId': teamId});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      Team t = Team.fromJson(decodedBody, parseMembers: true);
      t.retrieveUsernames();
      return t;
    } else
      return null;
  }



  // RIDES

  //To get the history of rides of a user
  Future<List<Ride>?> getAllRidesFromUser(String userID) async {
    var url = Uri.parse(baseUri + '/rides/getAllByUserId')
        .replace(queryParameters: {'userId': userID});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List<dynamic>;
      List<Ride> ridesList =
          decodedBody.map<Ride>((ride) => Ride.fromJson(ride)).toList();
      return ridesList;
    } else
      return null;
  }

  //Returns the recorded ride
  Future<Ride?> recordRide(Ride toRecord) async {
    var url = Uri.parse(baseUri + '/rides/record');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({
          "userId": toRecord.userId,
          "name": toRecord.name,
          "durationInSeconds": toRecord.durationInSeconds,
          "totalKm": toRecord.totalKm,
          "date": formatDate(toRecord.date),
          "elevationGain": toRecord.elevationGain,
          "path": toRecord.path
              ?.map((e) => {"latitude": e.latitude, "longitude": e.longitude})
              .toList()
        }));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      toRecord.pace = double.parse(decodedBody["pace"].toString());
      toRecord.points = double.parse(decodedBody["points"].toString());
      toRecord.rideId = decodedBody["id"];
      return toRecord;
    } else
      return null;
  }



  // REWARDS

  //Gets all the available rewards
  Future<List<Reward>?> getRewards() async {
    var url = Uri.parse(baseUri + '/rewards/list');
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Reward> rewardList =
          decodedBody.map<Reward>((reward) => Reward.fromJson(reward)).toList();
      return rewardList;
    } else
      return null;
  }

  //Redeem a reward
  Future<RedeemedReward?> redeemReward(String rewardId) async {
    var url = Uri.parse(baseUri + '/rewards/redeem');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode(
            {"userId": LoggedUser.instance!.userId, "rewardId": rewardId}));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      RedeemedReward newReward = RedeemedReward.fromJson(decodedBody);
      return newReward;
    } else
      return null;
  }

  // Get all rewards of a userId
  Future<List<RedeemedReward>?> getAllRewardsFromUser(String userId) async {
    var url = Uri.parse(baseUri + '/rewards/getByUser')
        .replace(queryParameters: {'userId': userId});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<RedeemedReward> rewardsList = decodedBody
          .map<RedeemedReward>((reward) => RedeemedReward.fromJson(reward))
          .toList();
      return rewardsList;
    } else
      return null;
  }




  // EVENTS

  //Returns an array of the events with the name matching the query if everything went fine
  //Returns null in case of error.
  //Used by team admins to search an event in which enroll the team identified by teamId
  Future<List<Event>?> searchEvent(String name, String teamId, String adminId) async {
    var url = Uri.parse(baseUri + '/events/search');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'adminId': adminId, 'name': name}));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Event> eventList =
      decodedBody.map<Event>((event) => Event.fromJson(event)).toList();
      return eventList;
    } else
      return null;
  }

  //Returns an array of the events with the name matching the query if everything went fine
  //Returns null in case of error
  //Used by a user to retrieve the list of joinable events
  Future<List<Event>?> getJoinableEvents(String userId) async {
    var url = Uri.parse(baseUri + '/events/getJoinableEvents')
        .replace(queryParameters: {'userId': userId});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Event> eventList =
      decodedBody.map<Event>((event) => Event.fromJson(event)).toList();
      return eventList;
    } else
      return null;
  }

  //Returns true if everything went fine, false otherwise.
  //Used by users to join events. teamId required if the event to join is a team event
  Future<bool> joinEvent(String eventId, String userId, {String? teamId}) async {
    var url = Uri.parse(baseUri + '/events/join');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'userId': userId, 'eventId': eventId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns the event if everything went fine, null otherwise.
  //Used by team admins to create private team events.
  Future<Event?> createPrivateTeamEvent(String adminId, String hostTeamId, String invitedTeamId,
      String name, String? description, DateTime startDate, DateTime endDate) async {
    var url = Uri.parse(baseUri + '/events/createPrivateTeam');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({
          'hostTeamId': hostTeamId,
          'invitedTeamId': invitedTeamId,
          'adminId': adminId,
          'name': name,
          'description': description,
          'startDate': formatDate(startDate),
          'endDate': formatDate(endDate)
        }));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      return Event.fromJson(decodedBody);
    } else
      return null;
  }

  //Returns the event if everything went fine, null otherwise.
  //Used by team admins to create public team events.
  Future<Event?> createPublicTeamEvent(String adminId, String hostTeamId,
      String name, String? description, DateTime startDate, DateTime endDate) async {
    var url = Uri.parse(baseUri + '/events/createPublicTeam');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({
          'hostTeamId': hostTeamId,
          'adminId': adminId,
          'name': name,
          'description': description,
          'startDate': formatDate(startDate),
          'endDate': formatDate(endDate)
        }));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      return Event.fromJson(decodedBody);
    } else
      return null;
  }

  //Returns true if everything went fine, false otherwise.
  //Used by team admins to subscribe one of their teams to a public event.
  Future<bool> enrollTeamToPublicEvent(String eventId, String adminId, String teamId) async {
    var url = Uri.parse(baseUri + '/events/enrollTeamPublic');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'adminId': adminId, 'eventId': eventId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns true if everything went fine, false otherwise.
  //Used by team admins to accept an invite to an event.
  Future<bool> acceptInvite(String eventId, String adminId, String teamId) async {
    var url = Uri.parse(baseUri + '/events/acceptPrivateTeamInvite');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'adminId': adminId, 'eventId': eventId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns true if everything went fine, false otherwise.
  //Used by team admins to reject an invite to an event.
  Future<bool> rejectInvite(String eventId, String adminId, String teamId) async {
    var url = Uri.parse(baseUri + '/events/rejectPrivateTeamInvite');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'adminId': adminId, 'eventId': eventId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns true if everything went fine, false otherwise.
  //Used by team admins to reject an invite to an event.
  Future<bool> sendInvite(String eventId, String adminId, String hostTeamId, String invitedTeamId) async {
    var url = Uri.parse(baseUri + '/events/invitePrivateTeam');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'hostTeamId': hostTeamId, 'invitedTeamId': invitedTeamId, 'adminId': adminId, 'eventId': eventId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns an array of the user's events
  //Returns null in case of error
  //Used by a user to retrieve the list of his events
  Future<List<Event>?> getUserEvents(String userId) async {
    var url = Uri.parse(baseUri + '/events/getUsersEvents');
    var response = await _serverClient.post(url, headers: _headers,
        body: json.encode({'userId': userId}));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Event> eventList =
      decodedBody.map<Event>((event) => Event.fromJson(event)).toList();
      return eventList;
    } else
      return null;
  }

  //Returns an array of the team's active events
  //Returns null in case of error
  Future<List<Event>?> getTeamActiveEvents(String teamId) async {
    var url = Uri.parse(baseUri + '/events/getTeamActiveEvents');
    var response = await _serverClient.post(url, headers: _headers,
        body: json.encode({'teamId': userId}));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Event> eventList =
      decodedBody.map<Event>((event) => Event.fromJson(event)).toList();
      return eventList;
    } else
      return null;
  }

  //Returns an array of the team's event requests
  //Returns null in case of error
  Future<List<Event>?> getTeamActiveEvents(String teamId) async {
    var url = Uri.parse(baseUri + '/events/getTeamEventRequests');
    var response = await _serverClient.post(url, headers: _headers,
        body: json.encode({'teamId': userId}));
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Event> eventList =
      decodedBody.map<Event>((event) => Event.fromJson(event)).toList();
      return eventList;
    } else
      return null;
  }

}
