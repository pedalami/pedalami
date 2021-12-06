import 'package:pedala_mi/models/mongoUser.dart';

class Team {
  String id;
  String adminId;
  String name;
  String? description;
  List<dynamic> members;

  Team(this.id, this.adminId, this.name, this.description, this.members);

  factory Team.fromJson(dynamic json) {
    var membersList = json['members'] as List;
    try {
      List<dynamic> userMembersList = membersList.map((member) => MongoUser.fromJson(member)).toList();
      return Team(json['_id'] as String, json['adminId'] as String, json['name'] as String, json['description'] as String?, userMembersList);
    } catch (ex) {
      try {
        List<String> membersIdList = membersList as List<String>;
        return Team(json['_id'] as String, json['adminId'] as String,
            json['name'] as String, json['description'] as String?,
            membersIdList);
      } catch (ex) {
        throw Exception("Impossible to decode Team JSON");
      }
    }
  }

  void setMembers(List<String> members) {
    this.members = members;
  }

  @override
  String toString() {
    return '{ Team ${this.name}, with id: ${this.id}. AdminId: ${this.adminId} }';
  }
}
