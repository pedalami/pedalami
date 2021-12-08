import 'dart:convert';

import 'package:flutter/material.dart';

class Badge{
  //String name;
  //String criteria;
  //num criteriaValue;
  String image;
  //String type;
  String description;

  Badge(this.image, this.description);

  factory Badge.fromJson(dynamic json) {
    return Badge(
        (json['image'] as String).substring("data:image/png;base64,".length+1),
        json['description'] as String
    );
  }

  @override
  String toString() {
    return 'Badge{ description: $description }';
  }

  /*
  factory Badge.fromJson(dynamic json) {
    return Badge(json['_id'] as String, json['criteria'] as String, json['criteria_value'] as num, json['image'] as String, json['type'] as String, json['description'] as String?);
  }
   */
}