import 'package:pedala_mi/models/mongoUser.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class Team {
  String id;
  String adminId;
  String name;
  String? description;
  List<String> membersId;
  List<MongoUser>? members;

  Team(this.id, this.adminId, this.name, this.description, this.membersId, this.members);

  factory Team.fromJson(dynamic json) {
    try {
      List<MongoUser> userMembersList = json['members'].map<MongoUser>((member) => MongoUser.fromJson(member)).toList();
      userMembersList.forEach((element) {
        MongoDB.instance.getUsername("userId").then((value) => element.userId = value);
      });
      return Team(json['_id'] as String, json['adminId'] as String, json['name'] as String,
          json['description'] as String?, userMembersList.map((team) => team.userId).toList(), userMembersList);
    } catch (ex, st) {
      //print("Cannot get full MongoUser");
      List<String> membersIdList = json['members'].map<String>((id) => id.toString()).toList();
      return Team(json['_id'] as String, json['adminId'] as String,
          json['name'] as String, json['description'] as String?,
          membersIdList, null);
    }
  }

  void setMembers(List<String> members) {
    this.membersId = members;
  }

  @override
  String toString() {
    return '{ Team ${this.name}, with id: ${this.id}. AdminId: ${this.adminId}.'
        'Members: ${this.membersId} }';
  }
}
