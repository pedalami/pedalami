import 'dart:ffi';

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

  //Given the id of a Team, it returns the entire team
  Future<Int8> getAirQualityIndexFromCoords(Float latitude, Float longitude) async {
    var url = Uri.parse(baseUri + '/forecast')
        .replace(queryParameters: {'lat': latitude, 'lon': longitude});
    var response = await _serverClient.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      var airQualityIndex = decodedBody['list'][0]['main']['aqi']
      return airQualityIndex;
    } else
      return null;
  }

}
