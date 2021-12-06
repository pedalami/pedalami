import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/models/ride.dart';

class MongoDB {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final MongoDB instance = new MongoDB();

  http.Client _serverClient = http.Client();
  String baseUri = "https://pedalami.herokuapp.com";

  Map<String, String> _headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  void localDebug() {
    baseUri = "http://localhost:8000";
  }

  //Returns true if everything went fine, false otherwise
  Future<bool> initUser(String userId) async {
    var url = Uri.parse(baseUri+'/users/initUser');
    var response = await _serverClient.post(url, headers: _headers, body: json.encode({'userId': userId}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns the team_id if everything went fine
  //Returns null in case of error
  Future<String?> createTeam(String adminId, String name, String? description) async {
    var url = Uri.parse(baseUri+'/teams/create');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'adminId': adminId, 'name': name, 'description': description})
    );
    if (response.statusCode == 200 && json.decode(response.body)["teamId"] != null) {
      return json.decode(response.body)["teamId"];
    } else
      return null;
  }

  //Returns an array of the teams with the name matching the query if everything went fine
  //Returns null in case of error
  Future<List<Team>?> searchTeam(String name) async {
    var url = Uri.parse(baseUri+'/teams/search').replace(queryParameters: {
      'name': name
    });
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Team> teamList = decodedBody.map((team) => Team.fromJson(team)).toList();
      return teamList;
    } else
      return null;
  }

  //Returns true if everything went fine, false otherwise
  Future<bool> joinTeam(String teamId, String userId) async {
    var url = Uri.parse(baseUri+'/teams/join');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'userId': userId})
    );
    return response.statusCode == 200 ? true : false;
  }
  
  Future<List<Ride>?> getAllRidesFromUser(String userID) async {
    var url = Uri.parse(baseUri+'/rides/getAllByUserId').replace(queryParameters: {
      'userId': userID
    });
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Ride> ridesList = decodedBody.map((ride) => Ride.fromJson(ride)).toList();
      return ridesList;
    } else
      return null;
  }

  Future<Ride?> recordRide(Ride toRecord) async {
    var url = Uri.parse(baseUri+'/rides/record');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({
          "userId": toRecord.userId,
          "name": toRecord.name,
          "durationInSeconds": toRecord.durationInSeconds,
          "totalKm": toRecord.totalKm,
          "date": toRecord.date,
          "elevationGain": toRecord.elevationGain})
    );
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      toRecord.pace = decodedBody["pace"];
      toRecord.points = decodedBody["points"];
      toRecord.rideId = decodedBody["id"];
      return toRecord;
    } else
      return null;
  }

}






/*
//Returns the recorded ride if everything went fine
  //Returns null in case of error
  Future<List<String>?> recordRide2(String userID, String name, int durationInSeconds, double totalKm, DateTime date, double elevationGain) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/rides/record');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({
          "uid": userID,
          "name": name,
          "durationInSeconds": durationInSeconds,
          "totalKm": totalKm,
          "date": date.toString(),
          "elevationGain": elevationGain})
          );
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List<String>;
      return decodedBody; //here, after implementing the ride class, we can return the ride object updated with the values in the serponse
      /*
      The response body has this structure:
      {
        "message": "Ride saved successfully",
        "points": 10100,
        "pace": 7200,
        "id": "61a53224c7a4d074a77aa6bc"
      }
      */
    } else
      return null;
  }
 */