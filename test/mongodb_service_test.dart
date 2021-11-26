import 'package:flutter_test/flutter_test.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

void main() {
  test('MongoDB interface testing', () async {
    var res = await MongoDB.instance.joinTeam("61a01e60e9364cc9bbf7056f", "15MkgTwMyOST77sinqjCzBhaPyE3");
    print(res);
  });
}

