import 'package:flutter/material.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/utils/date_time_ext.dart';
import 'package:search_choices/search_choices.dart';

class TeamEventItem extends StatefulWidget {
  const TeamEventItem(
      {Key? key, required Event event, required this.activeTeam})
      : event = event,
        super(key: key);
  final Event event;
  final Team activeTeam;

  @override
  _TeamEventItemState createState() => _TeamEventItemState();
}

class _TeamEventItemState extends State<TeamEventItem> {
  late Event event;
  late bool _rejected, _invited, _visible;
  late Team actualTeam;
  late String status;

  Team? selectedTeam;
  late Team? opposingTeam;
  late Team? host;
  var selectedValueSingleDialogFuture;
  bool loadingTeam = true;
  late bool pending;
  bool sendingInvite = false;

  @override
  void initState() {
    event = widget.event;
    status=setStatus();
    _rejected = event.isInviteRejected();
    _visible = true;
    actualTeam = widget.activeTeam;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await checkEventState();
      loadingTeam = false;
      setState(() {});
    });
    super.initState();
  }

  String setStatus()
  {
    if(event.isPrivate())
      {
        if(event.isInviteRejected())
          {
            return "Rejected";
          }
        else if(event.isInvitePending())
          {
            return "Pending";
          }
        else if(event.isInviteAccepted())
          {
            return "Accepted";
          }
        return "";

      }
    else
      {
        if(event.isApproved())
          {
            return "Approved";
          }
        else if(event.isPending())
          {
            return "Pending";
          }
        else if(event.isRejected())
          {
            return "Rejected";
          }
        return "";
      }
  }

  checkEventState() async {
    if (event.isInviteAccepted()) {
      opposingTeam = await MongoDB.instance.getTeam(event.guestTeam!.id);
    } else if (event.isInvitePending()) {
      opposingTeam = await MongoDB.instance.getTeam(event.involvedTeamsIds![0]);
    } else {
      opposingTeam = Team("", "", "", "", [], null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, right: 20, left: 20),
      child: Container(
        padding: EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                event.name,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Hosting Team: "+ actualTeam.name,
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 2 * SizeConfig.textMultiplier!),
                            ),
                          ],
                        ),
                      ),
                      event.isPrivate()
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: 1 * SizeConfig.heightMultiplier!),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Opposing Team: ",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            2 * SizeConfig.textMultiplier!),
                                  ),
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 250),
                                    child: !loadingTeam
                                        ? Text(
                                            opposingTeam!.name,
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier!),
                                          )
                                        : Container(
                                            height:
                                                2 * SizeConfig.textMultiplier!,
                                            width:
                                                2 * SizeConfig.textMultiplier!,
                                            child: CircularProgressIndicator(),
                                          ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Event Type: " +
                              (event.isPublic()
                                  ? "Public"
                                  : event.isPrivate()
                                      ? "Private"
                                      : ""),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Started: " + event.startDate.formatIT,
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Ends: " + event.endDate.formatIT,
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: Text(
                          "Status: " +status,
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 2 * SizeConfig.textMultiplier!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!),
                        child: !_rejected
                            ? SizedBox()
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Opposing team:",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 2 *
                                                  SizeConfig.textMultiplier!),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 9,
                                          child: SearchChoices.single(
                                            isExpanded: true,
                                            value:
                                                selectedValueSingleDialogFuture,
                                            hint: "Select opposing team",
                                            searchHint:
                                                "Write an opposing team...",
                                            onChanged: (value) {
                                              setState(() {
                                                selectedValueSingleDialogFuture =
                                                    value;
                                              });
                                            },
                                            selectedValueWidgetFn: (item) {
                                              selectedTeam = (item as Team);
                                              return (Center(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Text(selectedTeam!.name),
                                              )));
                                            },
                                            futureSearchFn: (String? keyword,
                                                String? orderBy,
                                                bool? orderAsc,
                                                List<Tuple2<String, String>>?
                                                    filters,
                                                int? pageNb) async {
                                              int nbResults = 0;
                                              List<DropdownMenuItem> results =
                                                  [];
                                              if (keyword != "") {
                                                List<Team>? teamsFound =
                                                    await MongoDB.instance
                                                        .searchTeam(keyword!);
                                                int sameTeamIndex = -1;
                                                for (int i = 0;
                                                    i < teamsFound!.length;
                                                    i++) {
                                                  if (teamsFound[i].id ==
                                                      actualTeam.id) {
                                                    sameTeamIndex = i;
                                                  }
                                                }
                                                if (sameTeamIndex != -1) {
                                                  teamsFound
                                                      .removeAt(sameTeamIndex);
                                                }
                                                nbResults = teamsFound.length;
                                                results = teamsFound
                                                    .map<DropdownMenuItem>(
                                                        (item) =>
                                                            DropdownMenuItem(
                                                              value: item,
                                                              child: Card(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  side:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(1),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(6),
                                                                  child: Text(
                                                                      item.name),
                                                                ),
                                                              ),
                                                            ))
                                                    .toList();
                                              }
                                              return (Tuple2<
                                                  List<DropdownMenuItem>,
                                                  int>(results, nbResults));
                                            },
                                            emptyListWidget: () => Text(
                                              "No result",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 250),
                                      child: sendingInvite
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.lightGreen),
                                                  shape: MaterialStateProperty
                                                      .all(RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      18.0),
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .lightGreen)))),
                                              child: Text("Invite Team"),
                                              onPressed: () async {
                                                if (selectedTeam != null) {
                                                  sendingInvite = true;
                                                  setState(() {});
                                                  try {
                                                    _invited = await MongoDB
                                                        .instance
                                                        .sendInvite(
                                                            event.id,
                                                            actualTeam.adminId,
                                                            actualTeam.id,
                                                            selectedTeam!.id);
                                                    if (_invited) {
                                                      _rejected = false;
                                                      status="Pending";
                                                      opposingTeam =
                                                          await MongoDB.instance
                                                              .getTeam(
                                                                  selectedTeam!
                                                                      .id);
                                                    }
                                                  } finally {
                                                    sendingInvite = false;
                                                    setState(() {});
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                      "Please select a team to invite!",
                                                    ),
                                                  ));
                                                }
                                              }),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
