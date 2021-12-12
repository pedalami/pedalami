import 'package:flutter/material.dart';
import 'package:pedala_mi/models/badge.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/models/ride.dart';
import 'package:pedala_mi/models/statistics.dart';
import 'team.dart';

class LoggedUser extends ChangeNotifier {
  String userId;
  NetworkImage image;
  String mail;
  String username;
  double? points;
  List<Team>? teams;
  Statistics? statistics;
  List<Badge>? badges;
  List<RedeemedReward>? redeemedRewards;
  List<Ride>? rideHistory;


  LoggedUser(this.userId, this.image, this.mail, this.username, this.points, this.teams, this.statistics, this.badges, this.redeemedRewards, this.rideHistory);

  static LoggedUser? instance;

  static initInstance(String userId, String imageUrl, String mail, String username) {
    instance = LoggedUser(userId, NetworkImage(imageUrl), mail, username, null, null, null, null, null, null);
  }

  static completeInstance(double points, List<Team> teams, Statistics stats, List<Badge> badges, List<RedeemedReward> rewards) {
    instance!.points = points;
    instance!.teams = teams;
    instance!.statistics = stats;
    instance!.badges = badges;
    instance!.redeemedRewards = rewards;
    instance!.notifyListeners();
  }

  List<Team> getNNTeams() {return teams ?? []; }
  List<Badge> getNNBadges() {return badges ?? []; }
  List<Reward> getNNRewards() {return redeemedRewards ?? []; }

  void setRideHistory(List<Ride>? rideHistory){
    this.rideHistory = rideHistory;
    this.notifyListeners();
  }
}
