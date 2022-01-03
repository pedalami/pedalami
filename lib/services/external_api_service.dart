import 'dart:ffi';

import 'package:http/http.dart' as http;


class AirQuality {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final AirQuality instance = new AirQuality();

  http.Client _serverClient = http.Client();
  String baseUri = "https://api.openweathermap.org/data/2.5/air_pollution";

  Map<String, String> _headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  //Given the id of a Team, it returns the entire team
  Future<String> getTeam(Float latitude, Float longitude) async {
    var url = Uri.parse(baseUri + '/forecast')
        .replace(queryParameters: {'lat': latitude, 'lon': longitude});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      String  = Team.fromJson(decodedBody, parseMembers: true);
      t.retrieveUsernames();
      return t;
    } else
      return null;
  }

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
      return null; //TODO add verbose error
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
      return null; //TODO add more verbose error
  }

  // Get all rewards of a userId
  Future<List<RedeemedReward>?> getAllRewardsFromUser(String userID) async {
    var url = Uri.parse(baseUri + '/rewards/getByUser')
        .replace(queryParameters: {'userId': userID});
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

  //Returns an array of the events with the name matching the query if everything went fine
  //Returns null in case of error
  Future<List<Event>?> searchEvent(String name) async {
    var url = Uri.parse(baseUri + '/events/search')
        .replace(queryParameters: {'name': name});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body) as List;
      List<Event> eventList =
      decodedBody.map<Event>((event) => Event.fromJson(event)).toList();
      return eventList;
    } else
      return null;
  }

  //Returns true if everything went fine, false otherwise
  //teamId is not used at the moment
  Future<bool> joinEvent(String eventId, String userId, {String? teamId}) async {
    var url = Uri.parse(baseUri + '/events/join');
    var response = await _serverClient.post(url,
        headers: _headers,
        body: json.encode({'teamId': teamId, 'userId': userId, 'eventId': eventId}));
    return response.statusCode == 200 ? true : false;
  }
}
