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

class Event{
  String id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String _type;
  String _visibility;
  double? prize;
  List<String>? enrolledTeamsIds;
  List<Team>? enrolledTeams;
  List<ScoreboardEntry>? scoreboard;


  Event(this.id,this.name, this.description, this.startDate, this.endDate, this._type,
      this._visibility, this.prize, this.enrolledTeamsIds, this.enrolledTeams, this.scoreboard);


  factory Event.fromJson(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
      .map<ScoreboardEntry>((e) => new ScoreboardEntry(
        e['userId'] as String,
        e['teamId'] as String?,
        double.parse(e['points'].toString()))
      ).toList();
    String type = json['type'] as String;
    String visibility = json['visibility'] as String;
    List<String>? enrolledTeamsIds;
    if (type == 'team') {
      if (visibility == 'public') {
        enrolledTeamsIds = (json['involvedTeams'] as List<dynamic>).map<String>((team) => team.toString()).toList();
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
      MongoDB.parseDate(json['startDate'] as String), //parse server date format
      MongoDB.parseDate(json['endDate'] as String),   //parse server date format
      type,
      visibility,
      double.tryParse(json['prize'].toString()),
      enrolledTeamsIds,
      null,
      scoreboard
    );
  }

  factory Event.fromJsonWithTeams(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
        .map<ScoreboardEntry>((e) => new ScoreboardEntry(
        e['userId'] as String,
        e['teamId'] as String?,
        double.parse(e['points'].toString()))
    ).toList();
    String type = json['type'] as String;
    String visibility = json['visibility'] as String;
    List<String>? enrolledTeamsIds;
    List<Team>? enrolledTeams;
    if (type == 'team') {
      if (visibility == 'public') {
        enrolledTeams = (json['involvedTeams'] as List<dynamic>).map<Team>((team) => Team.fromJson(team)).toList();
        enrolledTeamsIds = (json['involvedTeams'] as dynamic).map<String>((team) => team['_id'].toString()).toList();
      } else if (visibility == 'private') {
        enrolledTeamsIds = [];
        enrolledTeams = [];
        Team hostTeam = Team.fromJson(json['hostTeam'][0]);
        enrolledTeams.add(hostTeam);
        enrolledTeamsIds.add(hostTeam.id);
        Team? guestTeam;
        if(json['guestTeam'] != [] && json['guestTeam']!=null) {
          guestTeam = Team.fromJson(json['guestTeam'][0]);
          enrolledTeams.add(guestTeam);
          enrolledTeamsIds.add(guestTeam.id);
        }
      }
    }
    return Event(
        json['_id'] as String,
        json['name'] as String,
        json['description'] as String,
        MongoDB.parseDate(json['startDate'] as String), //parse server date format
        MongoDB.parseDate(json['endDate'] as String),   //parse server date format
        type,
        visibility,
        double.tryParse(json['prize'].toString()),
        enrolledTeamsIds,
        enrolledTeams,
        scoreboard
    );
  }


  bool isPublic() {
    return _visibility == "public";
  }
  bool isIndividual() {
    return _type == "individual";
  }

  String displayStartDate() {
    return DateFormat("yyyy-MM-dd HH:mm").format(startDate.toLocal());
  }

  String displayEndDate() {
    return DateFormat("yyyy-MM-dd HH:mm").format(endDate.toLocal());
  }

  @override
  String toString() {
    return 'Event { id: $id, name: $name, description: $description, start: '+displayStartDate()+
        ', end: '+displayEndDate()+', $_visibility, $_type }';
  }

}