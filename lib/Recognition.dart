library thirteen3_face_attendance;
import 'dart:ui';

import 'package:hive/hive.dart';

part 'Recognition.g.dart';

@HiveType(typeId: 1)
class Recognition {

  @HiveField(0)
  String name;

  @HiveField(1)
  String id;

  @HiveField(2)
  String image;

  @HiveField(3)
  List<double> embeddings;

  @HiveField(4)
  double distance;

  Recognition(this.id, this.name,this.image, this.embeddings, this.distance,);

  // Create a method to convert the object to a Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'image': image,
      'embeddings': embeddings,
      'distance': distance,
    };
  }

  // Create a factory constructor to create a Recognition object from a Map
  factory Recognition.fromJson(Map<String, dynamic> json) {
    return Recognition(
      json['id'],
      json['name'],
      json['image'],
      List<double>.from(json['embeddings']),
      json['distance'],
    );
  }
}