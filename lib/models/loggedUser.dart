import 'package:flutter/material.dart';
import 'package:pedala_mi/models/badge.dart';
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
  List<Badge>? badges;

  LoggedUser(this.userId, this.image, this.mail, this.username, this.points, this.teams, this.statistics, this.badges);

  static LoggedUser? instance;

  static initInstance(String userId, String imageUrl, String mail, String username) {
    instance = LoggedUser(userId, NetworkImage(imageUrl), mail, username, null, null, null, null);
  }

  static completeInstance(double points, List<Team> teams, Statistics stats, List<Badge> badges) {
    instance!.points = points;
    instance!.teams = teams;
    instance!.statistics = stats;
    instance!.badges = badges;
  }

}
