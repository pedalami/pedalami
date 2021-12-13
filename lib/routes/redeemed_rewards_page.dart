import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/redeemed_reward_item.dart';

class RedeemedRewardsPage extends StatefulWidget {
  const RedeemedRewardsPage({Key? key}) : super(key: key);

  @override
  _RedeemedRewardsPageState createState() => _RedeemedRewardsPageState();
}

class _RedeemedRewardsPageState extends State<RedeemedRewardsPage> {

  late bool loading;
  List<Reward> redeemedRewards=[];


  @override
  void initState() {
    loading=true;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      redeemedRewards=(await MongoDB.instance.getAllRewardsFromUser(FirebaseAuth.instance.currentUser!.uid))!;
      loading=false;
      setState(() {

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.green[600],
                height: 20 * SizeConfig.heightMultiplier!,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 3 * SizeConfig.heightMultiplier!),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Redeemed rewards", style: TextStyle(color: Colors.white, fontSize: 30),),
                    ],
                  ),
                ),
              ),
              loading?Text("Loading..."):(redeemedRewards.length==0?Text("No redeemed rewards"):
              RedeemedRewardItem(rewards: redeemedRewards))
            ],
          ),
        )
    );
  }
}
