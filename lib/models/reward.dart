import 'package:flutter_osm_interface/flutter_osm_interface.dart';

class Reward {
  String id;
  double price;
  String description;
  String image;
  
  Reward(this.id, this.price, this.description, this.image);

  factory Reward.fromJson(dynamic json) {
    return Reward(
        json['_id'] as String,
        double.parse(json['price'].toString()),
        json['description'] as String,
        json['image'] as String
    );
  }

  @override
  String toString() {
    return 'Reward{ id: $id, price: $price, description: $description}';
  }
}

class RedeemedReward extends Reward{

  String redeemedDate;
  String rewardContent;

  RedeemedReward(id, price, description, image, this.redeemedDate, this.rewardContent) : super(id, price , description, image);

  factory RedeemedReward.fromJson(dynamic json) {
    return RedeemedReward(
        json['selected_reward']['_id'] as String,
        double.parse(json['selected_reward']['price'].toString()),
        json['selected_reward']['description'] as String,
        json['selected_reward']['image'] as String,
        json['generated_reward']['redeemedDate'] as String,
        json['generated_reward']['rewardContent'] as String
    );
  }

  @override
  String toString() {
    return 'RedeemedReward{id: $id, price: $price, description: $description, image: $image, redeemedDate: $redeemedDate, rewardContent: $rewardContent}';
  }

}