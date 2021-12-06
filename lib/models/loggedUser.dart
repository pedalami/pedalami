import 'package:flutter/material.dart';
import 'package:pedala_mi/models/statistics.dart';
import 'team.dart';

class LoggedUser {
  String userId;
  NetworkImage image;
  String mail;
  String username;
  double? points;
  List<Team>? teams;
  Statistics? statistics;

  LoggedUser(this.userId, this.image, this.mail, this.username, this.points, this.teams, this.statistics);

  static LoggedUser? instance;

  static initInstance(String userId, String imageUrl, String mail, String username) {
    instance = LoggedUser(userId, NetworkImage(imageUrl), mail, username, null, null, null);
  }

  static completeInstance(double points, List<Team> teams, Statistics stats) {
    instance!.points = points;
    instance!.teams = teams;
    instance!.statistics = stats;
  }

}
