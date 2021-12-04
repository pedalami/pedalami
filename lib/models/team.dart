import 'package:pedala_mi/models/user.dart';

class Team {
  String uid;
  String adminId;
  String name;
  String? description;
  List<dynamic> members;


  Team(this.uid, this.adminId, this.name, this.description, this.members);

  factory Team.fromJson(dynamic json) {
    return Team(json['_id'] as String, json['admin_uid'] as String, json['name'] as String, json['description'] as String?, json['members']);
  }

  void setMembers(List<String> members) {
    this.members = members;
  }

  @override
  String toString() {
    return '{ Team ${this.name}, with id: ${this.uid}. AdminID: ${this.adminId} }';
  }
}
