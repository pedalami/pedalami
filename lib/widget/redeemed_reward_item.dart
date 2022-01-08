import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pedala_mi/models/reward.dart';

class RedeemedRewardItem extends StatefulWidget {
  const RedeemedRewardItem({
    Key? key,
    required List<RedeemedReward> rewards,
  })  : rewards = rewards,
        super(key: key);
  final List<RedeemedReward> rewards;

  @override
  _RedeemedRewardItemState createState() => _RedeemedRewardItemState();
}

class _RedeemedRewardItemState extends State<RedeemedRewardItem> {
  late List<RedeemedReward> rewards;

  @override
  void initState() {
    rewards = widget.rewards;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rewards.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, i) {
        String price = rewards[i].price.toStringAsFixed(0);
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex:2,
                  child: Image.memory(base64Decode(rewards[i]
                      .image
                      .replaceAll("data:image/png;base64,", "")
                      .replaceAll("\"", ""))),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Description:",
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        rewards[i].description,
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        "Content:",
                        style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        rewards[i].rewardContent,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.grey),
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.grey)))),
                  child:
                      Text(price + (price == "1" ? " point" : " points")),
                  onPressed: () {},
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
