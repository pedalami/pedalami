import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/widget/get_reward_button.dart';

class RewardItem extends StatefulWidget {
  const RewardItem({Key? key, required List<Reward> rewards, required notifyParent}) : rewards=rewards,notifyParent=notifyParent,super(key: key);
  final List<Reward> rewards;
  final Function() notifyParent;


  @override
  _RewardItemState createState() => _RewardItemState();
}

class _RewardItemState extends State<RewardItem> {
  late List<Reward> rewards;
  List<bool> buttonClicked=[];


  @override
  void initState() {
    rewards=widget.rewards;
    super.initState();
  }

  refresh() {
    widget.notifyParent();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rewards.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, i){
        buttonClicked.add(false);
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            height: MediaQuery.of(context).size.height * .1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(border: Border(
              bottom: BorderSide( color: Colors.grey),
            ),
              color: Colors.white,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.memory(base64Decode(rewards[i].image.replaceAll("data:image/png;base64,","").replaceAll("\"", ""))),
                ],
              ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Description:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  Text(rewards[i].description, style: TextStyle(fontSize: 15),),],
              ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GetRewardButton(reward: rewards[i],alreadyClicked: buttonClicked[i],notifyParent: refresh),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
