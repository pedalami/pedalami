import 'package:intl/intl.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';


class ScoreboardEntry {
  String userId;
  String? teamId;
  double points;

  ScoreboardEntry(this.userId, this.teamId, this.points);
}

class TeamScoreboardEntry {
  String teamId;
  double points;

  TeamScoreboardEntry(this.teamId, this.points);
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


  List<ScoreboardEntry>? scoreboard;


  //Start of public team events attributes
  List<String>? involvedTeamsIds;
  //Only for public team events when the getUsersEvents is called
  List<Team>? enrolledTeams;
  //Only for public team events when the getUsersEvents is called
  List<TeamScoreboardEntry>? teamScoreboard;
  String? status;
  // End of public team events attributes

  Event(
      this.id,
      this.name,
      this.description,
      this.startDate,
      this.endDate,
      this._type,
      this._visibility,
      this.prize,
      this.status,
      this.hostTeamId,
      this.guestTeamId,
      this.hostTeam,
      this.guestTeam,
      this.pendingRequest,
      this.involvedTeamsIds,
      this.enrolledTeams,
      this.scoreboard,
      this.teamScoreboard);

  factory Event.fromJson(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
        .map<ScoreboardEntry>((e) => new ScoreboardEntry(e['userId'] as String,
        e['teamId'] as String?, double.parse(e['points'].toString())))
        .toList();
    scoreboard.sort((a,b)=>b.points.compareTo(a.points));
    String type = json['type'] as String;
    String visibility = json['visibility'] as String;
    List<String>? involvedTeamsIds;
    String? pendingRequest;
    if (type == 'team') {
      /*teamScoreboard = (json['teamScoreboard'] as List<dynamic>?)?.map<TeamScoreboardEntry>(
        (e) => new TeamScoreboardEntry(e['teamId'] as String, double.parse(e['points'].toString()))
      ).toList();*/
      involvedTeamsIds = (json['involvedTeams'] as List<dynamic>?)?.map<String>((team) => team.toString()).toList();
      if (visibility == 'private') {
        pendingRequest = null;
        if (involvedTeamsIds != null && involvedTeamsIds.isNotEmpty) {
          pendingRequest = involvedTeamsIds.first;
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
        json['status'] as String?,
        json['hostTeam'] as String?,
        json['guestTeam'] as String?,
        null,
        null,
        pendingRequest,
        involvedTeamsIds,
        null,
        scoreboard,
        null);
  }

  factory Event.fromJsonWithTeams(dynamic json) {
    List<ScoreboardEntry> scoreboard = (json['scoreboard'] as List<dynamic>)
        .map<ScoreboardEntry>((e) => new ScoreboardEntry(e['userId'] as String,
        e['teamId'] as String?, double.parse(e['points'].toString())))
        .toList();
    scoreboard.sort((a,b)=>b.points.compareTo(a.points));
    List<TeamScoreboardEntry>? teamScoreboard;
    String type = json['type'] as String;
    String visibility = json['visibility'] as String;
    List<String>? involvedTeamsIds;
    List<Team>? enrolledTeams;
    Team? hostTeam;
    Team? guestTeam;
    String? pendingRequest;
    if (type == 'team') {
      teamScoreboard = (json['teamScoreboard'] as List<dynamic>?)?.map<TeamScoreboardEntry>(
              (e) => new TeamScoreboardEntry(e['teamId'] as String, double.parse(e['points'].toString()))
      ).toList();
      teamScoreboard?.sort((a,b)=>b.points.compareTo(a.points));
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
        json['status'] as String?,
        hostTeam?.id,
        guestTeam?.id,
        hostTeam,
        guestTeam,
        pendingRequest,
        involvedTeamsIds,
        enrolledTeams,
        scoreboard,
        teamScoreboard);
  }

  bool isPublic() {
    return _visibility == "public";
  }

  bool isPrivate() {
    return _visibility == "private";
  }

  bool isTeam() {
    return _type == "team";
  }

  bool isIndividual() {
    return _type == "individual";
  }

  bool isApproved() {
    return isPublic() &&
        isTeam() &&
        status == "approved"
        ? true
        : false;
  }

  bool isPending() {
    return isPublic() &&
        isTeam() &&
        status == "pending"
        ? true
        : false;
  }

  bool isRejected() {
    return isPublic() &&
        isTeam() &&
        status == "rejected"
        ? true
        : false;
  }

  bool isInviteAccepted() {
    return isPrivate() &&
        isTeam() &&
        guestTeam != null &&
        pendingRequest == null
        ? true
        : false;
  }

  bool isInvitePending() {
    return isPrivate() &&
        isTeam() &&
        guestTeam == null &&
        pendingRequest != null
        ? true
        : false;
  }

  bool isInviteRejected() {
    return isPrivate() &&
        isTeam() &&
        guestTeam == null &&
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

  Team? getTeamFromTSEntry(TeamScoreboardEntry tse) {
    Team? toReturn;
    enrolledTeams?.forEach((team) {
      if (team.id == tse.teamId)
        toReturn = team;
    });
    return toReturn;
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
