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
        (json['image'] as String).split(',').last,
        json['description'] as String
    );
  }

  @override
  String toString() {
    return 'Badge{ description: $description }';
  }

}