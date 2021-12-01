import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pedala_mi/models/team.dart';

class MongoDB {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final MongoDB instance = new MongoDB();

  http.Client _serverClient = http.Client();

  Map<String, String> _headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  //Returns true if everything went fine, false otherwise
  Future<bool> initUser(String uid) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/users/create');
    var response = await _serverClient.post(url, headers: _headers, body: json.encode({'uid': uid}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns the team_id if everything went fine
  //Returns null in case of error
  Future<String?> createTeam(String adminId, String name, String? description) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/teams/create');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'admin_uid': adminId, 'name': name, 'description': description})
    );
    if (response.statusCode == 200 && json.decode(response.body)["team_id"] != null) {
      return json.decode(response.body)["team_id"];
    } else {
      return null;
    }
  }

  //Returns an array of the teams with the name matching the query if everything went fine
  //Returns null in case of error
  Future<List<Team>?> searchTeam(String name) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/teams/search').replace(queryParameters: {
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
  Future<bool> joinTeam(String teamID, String userID) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/teams/join');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'team_id': teamID, 'uid': userID})
    );
    return response.statusCode == 200 ? true : false;
  }

  //Returns the recorded ride if everything went fine
  //Returns null in case of error
  Future<List<String>?> recordRide(String userID, String name, int durationInSeconds, double total_km, Date date, double elevation_gain) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/rides/record');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({
          "uid": userID,
          "name": name,
          "duration_in_seconds": durationInSeconds,
          "total_km": total_km,
          "date": date.toString(),
          "elevation_gain": elevation_gain})
          );
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
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

}
