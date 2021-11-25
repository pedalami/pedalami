import 'package:pedala_mi/models/user.dart';

class Team {
  String uid;
  String adminId;
  String name;
  List<MiUser>? members;


  Team(this.uid, this.adminId, this.name, this.members);

  factory Team.fromJson(dynamic json) {
    return Team(json['_id'] as String, json['admin_uid'] as String, json['name'] as String, null);
  }

  void setMembers(List<MiUser> members) {
    this.members = members;
  }

  @override
  String toString() {
    return '{ Team ${this.name}, with id: ${this.uid}. AdminID: ${this.adminId} }';
  }
}
