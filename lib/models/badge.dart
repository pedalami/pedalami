class Badge{
  String uid;
  String criteria;
  num criteriaValue;
  String image;
  String type;

  Badge(this.uid, this.criteria, this.criteriaValue, this.image, this.type);

  factory Badge.fromJson(dynamic json) {
    return Badge(json['_id'] as String, json['criteria'] as String, json['criteria_value'] as num, json['image'] as String, json['type'] as String);
  }
}