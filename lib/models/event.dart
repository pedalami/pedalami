import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<ScoreboardEntry>? scoreboard;


  Event(this.id,this.name, this.description, this.startDate, this.endDate, this._type,
      this._visibility, this.prize, this.scoreboard);


  factory Event.fromJson(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
      .map<ScoreboardEntry>((e) => new ScoreboardEntry(
        e['userId'] as String,
        e['teamId'] as String?,
        double.parse(e['points'].toString()))
      ).toList();
    return Event(
      json['_id'] as String,
      json['name'] as String,
      json['description'] as String,
      MongoDB.parseDate(json['startDate'] as String), //parse server date format
      MongoDB.parseDate(json['endDate'] as String),   //parse server date format
      json['type'] as String,
      json['visibility'] as String,
      double.tryParse(json['prize'].toString()),
      scoreboard
    );
  }

  bool isPublic() {
    return _visibility == "public";
  }
  bool isTeam() {
    return _type == "team";
  }
  bool isPrivate() {
    return _visibility == "private";
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
    return 'Event{ id: $id, name: $name, description: $description, start: '+displayStartDate()+
        ', end: '+displayEndDate()+', $_visibility, $_type';
  }

}