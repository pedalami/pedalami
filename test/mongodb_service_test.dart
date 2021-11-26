import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

void main() {
  test('MongoDB interface testing', () async {
    var res = await MongoDB.instance.createTeam("15MkgTwMyOST77sinqjCzBhaPyE3","superprova", null);
    print(res);
  });
}

