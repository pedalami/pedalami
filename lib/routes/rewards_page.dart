import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/routes/redeemed_rewards_page.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/reward_item.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({Key? key}) : super(key: key);

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  List<Reward> rewards = [];
  late bool loading;
  String points="";

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    loading = true;
    LoggedUser.instance!.addListener(() => setState(() {}));
    points = LoggedUser.instance!.points!.toStringAsFixed(0);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      rewards = (await MongoDB.instance.getRewards())!;
      loading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          height: 50,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.green,
            heroTag: "btnShowRedeemedRewards",
            onPressed: () {
              pushNewScreen(context, screen: RedeemedRewardsPage());
            },
            label: Text("Redeemed Rewards", style: TextStyle(color: Colors.white),),
            icon: Icon(Icons.list, color: Colors.white,),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.green[600],
                height: 20 * SizeConfig.heightMultiplier!,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 3 * SizeConfig.heightMultiplier!),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Rewards",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                      Text(
                        "You currently have " +
                            LoggedUser.instance!.points!.toStringAsFixed(0) +
                            (LoggedUser.instance!.points!.toStringAsFixed(0) == "1" ? " point" : " points"),
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              loading
                  ? Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.width*.5,),
                      CircularProgressIndicator(color: Colors.green[600],),
                      SizedBox(height: MediaQuery.of(context).size.width*.05,),
                      Text("Loading...", style: TextStyle(fontSize: 17),)
                    ],
                  )
                  : (rewards.length == 0 ?
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.width*.6,),
                  Text("No rewards available.", style: TextStyle(fontSize: 17, color: Colors.grey),)
                ],
              )
                      : RewardItem(rewards: rewards, notifyParent: refresh)),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ));
  }
}
