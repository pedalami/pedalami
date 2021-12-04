import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

void main() {
  test('MongoDB interface testing', () async {
    var res = await MongoDB.instance.createTeam("15MkgTwMyOST77sinqjCzBhaPyE3","superprova", null);
    print(res);

    Ride? ride = new Ride("15MkgTwMyOST77sinqjCzBhaPyE3", "first_test_ride", 20, 0.1, null,
        "2021-12-03", 0.4, null);
    ride = await MongoDB.instance.recordRide(ride);
    if (ride != null){
      print(ride.toString());
    }
    else{
      print("Error while saving the ride");
    }
  });


}

