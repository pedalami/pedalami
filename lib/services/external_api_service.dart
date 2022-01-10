import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pedala_mi/utils/mobile_library.dart';



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

  //Given a set of coordinates, it returns and AirQuality index for the area
  // 1 for good, 2 for poor, 3 for moderate, 4 for poor, 5 for very poor
  // -1 in case of error
  Future<int> getAirQualityIndexFromCoords(double latitude, double longitude) async {
    var url = Uri.parse(baseUri + '/forecast')
        .replace(queryParameters: {'lat': latitude.toString(), 'lon': longitude.toString(), 'appid': 'f01bcf9b8d8f2aedde4fa855cbcdd02b'});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      var airQualityIndex = decodedBody['list'][0]['main']['aqi'];
      return airQualityIndex;
    } else
      return -1;
  }

}

class Weather {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final Weather instance = new Weather();

  http.Client _serverClient = http.Client();
  String baseUri = "https://api.openweathermap.org/data/2.5/weather";

  Map<String, String> _headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  //Given the id of a Team, it returns the entire team
  Future<int> getWeatherFromCoords(double latitude, double longitude) async {
    var url = Uri.parse(baseUri)
        .replace(queryParameters: {'lat': latitude.toString(), 'lon': longitude.toString(), 'appid': 'f01bcf9b8d8f2aedde4fa855cbcdd02b'});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      //print(decodedBody);
      var weatherId = decodedBody['weather'][0]['id'];
      print(weatherId);
      return weatherId;
    } else
      return -1;
  }

}