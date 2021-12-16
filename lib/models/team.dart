import 'package:flutter/foundation.dart';
import 'package:pedala_mi/models/mongoUser.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class Team extends ChangeNotifier {
  String id;
  String adminId;
  String name;
  String? description;
  List<String> membersId;
  Map<String, MongoUser>? members;

  Team(this.id, this.adminId, this.name, this.description, this.membersId, this.members);

  factory Team.fromJson(dynamic json, {bool parseMembers = false}) {
    if (!parseMembers) {
      List<String> membersIdList = json['members'].map<String>((id) =>
          id.toString()).toList();
      return Team(json['_id'] as String, json['adminId'] as String,
          json['name'] as String, json['description'] as String?,
          membersIdList, null);
    } else {
      Map<String, MongoUser> membersMap =
      Map.fromIterable(
          json['members']
          .map<MongoUser>((member) => MongoUser.fromJson(member)).toList(),
          key: (e) => e.userId,
          value: (e) => e
      );
      return Team(json['_id'] as String, json['adminId'] as String,
          json['name'] as String, json['description'] as String?,
          membersMap.keys.toList(), membersMap);
    }
  }

  String getNNDescription() {
    return description ?? "";
  }

  void retrieveUsernames() {
    this.members?.values.forEach((element) {
      MongoDB.instance.getUsername(element.userId).then((value) {element.username = value; this.notifyListeners();});
    });
  }

  String? getAdminName() {
    return members?[this.adminId]?.username;
  }

  @override
  String toString() {
    return '{ Team ${this.name}, with id: ${this.id}. AdminId: ${this.adminId}.'
        'Members: ${this.membersId} }';
  }
}
