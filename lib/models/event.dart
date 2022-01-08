import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class ScoreboardEntry {
  String userId;
  String? teamId;
  double points;

  ScoreboardEntry(this.userId, this.teamId, this.points);
}

class Event {
  String id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String _type;
  String _visibility;
  double? prize;

  // Start of private event attributes
  String? hostTeamId;
  String? guestTeamId;
  Team?
      hostTeam; //Only for private team events when the getUsersEvents is called
  Team?
      guestTeam; //Only for private team events when the getUsersEvents is called
  String? pendingRequest;
  // End of private event attributes

  List<Team>?
      enrolledTeams; //Only for public team events when the getUsersEvents is called
  List<String>? involvedTeamsIds; //Only for public team events
  List<ScoreboardEntry>? scoreboard;

  Event(
      this.id,
      this.name,
      this.description,
      this.startDate,
      this.endDate,
      this._type,
      this._visibility,
      this.prize,
      this.hostTeamId,
      this.guestTeamId,
      this.hostTeam,
      this.guestTeam,
      this.pendingRequest,
      this.involvedTeamsIds,
      this.enrolledTeams,
      this.scoreboard);

  factory Event.fromJson(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
        .map<ScoreboardEntry>((e) => new ScoreboardEntry(e['userId'] as String,
            e['teamId'] as String?, double.parse(e['points'].toString())))
        .toList();
    String type = json['type'] as String;
    String visibility = json['visibility'] as String;
    List<String>? enrolledTeamsIds;
    if (type == 'team') {
      if (visibility == 'public') {
        enrolledTeamsIds = (json['involvedTeams'] as List<dynamic>)
            .map<String>((team) => team.toString())
            .toList();
      } else if (visibility == 'private') {
        enrolledTeamsIds = [];
        enrolledTeamsIds.add(json['hostTeam'] as String);
        String? guestTeam = json['guestTeam'] as String?;
        if (guestTeam != null) enrolledTeamsIds.add(guestTeam);
      }
    }
    return Event(
        json['_id'] as String,
        json['name'] as String,
        json['description'] as String,
        MongoDB.parseDate(
            json['startDate'] as String), //parse server date format
        MongoDB.parseDate(json['endDate'] as String), //parse server date format
        type,
        visibility,
        double.tryParse(json['prize'].toString()),
        json['hostTeam'] as String?,
        json['guestTeam'] as String?,
        null,
        null,
        pendingRequest,
        involvedTeamsIds,
        null,
        scoreboard);
  }

  factory Event.fromJsonWithTeams(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
        .map<ScoreboardEntry>((e) => new ScoreboardEntry(e['userId'] as String,
            e['teamId'] as String?, double.parse(e['points'].toString())))
        .toList();
    String type = json['type'] as String;
    String visibility = json['visibility'] as String;
    List<String>? involvedTeamsIds;
    List<Team>? enrolledTeams;
    Team? hostTeam;
    Team? guestTeam;
    String? pendingRequest;
    if (type == 'team') {
      enrolledTeams = (json['involvedTeams'] as List<dynamic>?)
          ?.map<Team>((team) => Team.fromJson(team))
          .toList();
      involvedTeamsIds = enrolledTeams?.map((e) => e.id).toList();
      if (visibility == 'private') {
        hostTeam = Team.fromJson(json['hostTeam'][0]);
        if (json['guestTeam'] != [] && json['guestTeam'] != null) {
          // if the private team event has a guestTeam
          guestTeam = Team.fromJson(json['guestTeam'][0]);
        } else {
          // if there is no opponent team
          pendingRequest = involvedTeamsIds?.first;
        }
      }
    }
    return Event(
        json['_id'] as String,
        json['name'] as String,
        json['description'] as String,
        MongoDB.parseDate(
            json['startDate'] as String), //parse server date format
        MongoDB.parseDate(json['endDate'] as String), //parse server date format
        type,
        visibility,
        double.tryParse(json['prize'].toString()),
        hostTeam?.id,
        guestTeam?.id,
        hostTeam,
        guestTeam,
        pendingRequest,
        involvedTeamsIds,
        enrolledTeams,
        scoreboard);
  }

  bool isPublic() {
    return _visibility == "public";
  }

  bool isIndividual() {
    return _type == "individual";
  }

  bool isInviteAccepted() {
    return isPrivate() &&
            isTeam() &&
            guestTeamId != null &&
            pendingRequest == null
        ? true
        : false;
  }

  bool isInvitePending() {
    return isPrivate() &&
            isTeam() &&
            guestTeamId == null &&
            pendingRequest != null
        ? true
        : false;
  }

  bool isInviteRejected() {
    return isPrivate() &&
            isTeam() &&
            guestTeamId == null &&
            pendingRequest == null
        ? true
        : false;
  }

  String displayStartDate() {
    return DateFormat("yyyy-MM-dd HH:mm").format(startDate.toLocal());
  }

  String displayEndDate() {
    return DateFormat("yyyy-MM-dd HH:mm").format(endDate.toLocal());
  }

  @override
  String toString() {
    return 'Event { id: $id, name: $name, description: $description, start: ' +
        displayStartDate() +
        ', end: ' +
        displayEndDate() +
        ', $_visibility, $_type }';
  }
}
