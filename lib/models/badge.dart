class Badge{
  String uid;
  String criteria;
  num criteriaValue;
  String image;
  String type;
  String? description;

  Badge(this.uid, this.criteria, this.criteriaValue, this.image, this.type, this.description);

  factory Badge.fromJson(dynamic json) {
    return Badge(json['_id'] as String, json['criteria'] as String, json['criteria_value'] as num, json['image'] as String, json['type'] as String, json['description'] as String?);
  }
}