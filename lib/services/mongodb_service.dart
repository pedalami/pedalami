import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pedala_mi/models/team.dart';

class MongoDB {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final MongoDB instance = new MongoDB();

  @protected
  http.Client serverClient = http.Client();

  @protected
  Map<String, String> headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  //Returns true if everything went fine, false otherwise
  Future<bool> initUser(String uid) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/users/create');
    var response = await serverClient.post(url, headers: headers, body: json.encode({'uid': uid}));
    return response.statusCode == 200 ? true : false;
  }

  //Returns the team_id if everything went fine
  //Returns null in case of error
  //DART code should be fine, server side needs some fixes
  Future<String?> createTeam(String adminId, String name) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/teams/create');
    var response = await serverClient.post(url,
        headers: headers,
        body: json.encode({'admin_uid': adminId, 'name': name})
    );
    if (response.statusCode == 200 && json.decode(response.body)["team_id"]) {
      return json.decode(response.body)["team_id"];
    } else {
      print(response.statusCode);
      print(response.body);
      return null;
    }
  }

  //Returns an array of the teams with the name matching the query if everything went fine
  //Returns null in case of error
  //TESTED
  Future<List<Team>?> searchTeam(String name) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/teams/search').replace(queryParameters: {
      'name': name
    });
    var response = await serverClient.get(url, headers: headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Team> teamList = decodedBody.map((team) => Team.fromJson(team)).toList();
      return teamList;
    } else
      return null;
  }

  //Returns true if everything went fine, false otherwise
  //TO TEST
  Future<bool> joinTeam(String teamID, String userID) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/teams/join');
    var response = await serverClient.post(url,
        headers: headers,
        body: json.encode({'team_id': teamID, 'userID': userID})
    );
    return response.statusCode == 200 ? true : false;
  }

}
