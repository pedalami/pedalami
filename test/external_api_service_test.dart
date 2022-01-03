
import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/services/external_api_service.dart';

AirQuality instance = AirQuality.instance;

void main() {
  test('airQuality testing', () async {
    var latitude = "40.4";
    var longitude = "14.4";
    int res = await instance.getAirQualityIndexFromCoords(latitude, longitude);
    print(res);

    assert(res != -1);
  });
}
