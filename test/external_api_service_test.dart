
import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/services/external_api_service.dart';

AirQuality instance = AirQuality.instance;
Weather instance = Weather().instance;

void main() {
  test('weather testing', () async {
    var latitude = 40.4;
    var longitude = 14.4;
    int res = await instance.getWeatherFromCoords(latitude, longitude);
    print(res);

    assert(res != -1);
  });
}
