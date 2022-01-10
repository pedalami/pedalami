import 'package:flutter/material.dart';
import 'package:pedala_mi/assets/custom_colors.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

class GetRewardButton extends StatefulWidget {
  const GetRewardButton(
      {Key? key,
      required bool alreadyClicked,
      required Reward reward,
      @required notifyParent})
      : reward = reward,
        alreadyClicked = alreadyClicked,
        notifyParent = notifyParent,
        super(key: key);
  final Function() notifyParent;
  final bool alreadyClicked;
  final Reward reward;

  @override
  _GetRewardButtonState createState() => _GetRewardButtonState();
}

class _GetRewardButtonState extends State<GetRewardButton> {
  late bool _alreadyClicked;
  late Reward reward;

  @override
  void initState() {
    reward = widget.reward;
    _alreadyClicked = widget.alreadyClicked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String price = reward.price.toStringAsFixed(0);
    if (LoggedUser.instance!.points! < reward.price) {
      return ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.grey)))),
          child: Text(price + (price == "1" ? " point" : " points")),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("You don\'t have enough points for " +
                    reward.description +
                    "!")));
          });
    } else {
      return ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.green)))),
          child: !_alreadyClicked
              ? AnimatedCrossFade(
                  duration: Duration(milliseconds: 100),
                  crossFadeState: _alreadyClicked
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild:
                      Text(price + (price == "1" ? " point" : " points")),
                  secondChild: Text('GET'))
              : AnimatedCrossFade(
                  duration: Duration(milliseconds: 100),
                  crossFadeState: !_alreadyClicked
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild:
                      Text(price + (price == "1" ? " point" : " points")),
                  secondChild: Text('GET')),
          onPressed: () {
            if (_alreadyClicked) {
              showDialog<bool>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      "",
                      style: TextStyle(color: Colors.black),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            "Are you sure to redeem " +
                                reward.description +
                                " for " +
                                price +
                                (price == "1" ? " point" : " points") +
                                "?",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'YES',
                          style: TextStyle(color: CustomColors.green),
                        ),
                        onPressed: () async {
                          var redeemedReward =
                              await MongoDB.instance.redeemReward(reward.id);
                          if (redeemedReward != null) {
                            LoggedUser.instance!.points =
                                LoggedUser.instance!.points! - reward.price;
                            if (LoggedUser.instance!.redeemedRewards == null) {
                              LoggedUser.instance!.redeemedRewards =
                                  List.empty(growable: true);
                            }
                            LoggedUser.instance!.redeemedRewards!
                                .add(redeemedReward);
                            LoggedUser.instance!.notifyListeners();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("You have redeemed your reward!")));
                            widget.notifyParent();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "You don't have enough points for " +
                                        reward.description +
                                        "!")));
                          }
                          buttonUpdate(context);
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            buttonUpdate(context);
                          },
                          child: Text('NO',
                              style: TextStyle(color: CustomColors.green))),
                    ],
                  );
                },
              );
            } else {
              setState(() {
                _alreadyClicked = true;
              });
            }
          });
    }
  }

  void buttonUpdate(BuildContext context) {
    Navigator.of(context).pop();
    setState(() {
      _alreadyClicked = false;
    });
  }
}
