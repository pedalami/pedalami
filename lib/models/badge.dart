
class Badge{
  //String name;
  //String criteria;
  //num criteriaValue;
  String image; //image in base64
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