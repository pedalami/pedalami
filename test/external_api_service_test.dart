
import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/services/external_api_service.dart';

AirQuality airQualityInstance = AirQuality.instance;
Weather weatherInstance = Weather.instance;

void main() {
  test('air quality testing', () async {
    var latitude = 40.4;
    var longitude = 14.4;
    int res = await airQualityInstance.getAirQualityIndexFromCoords(latitude, longitude);
    print(res);

    assert(res != -1);
  });

  test('weather testing', () async {
    var latitude = 40.4;
    var longitude = 14.4;
    int res = await weatherInstance.getWeatherFromCoords(latitude, longitude);
    print(res);

    assert(res != -1);
  });
}
