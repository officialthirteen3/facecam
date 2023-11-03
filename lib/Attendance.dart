library thirteen3_face_attendance;

import 'dart:ui';

import 'package:hive/hive.dart';

part 'Attendance.g.dart';

@HiveType(typeId: 2)
class Attendance {

  @HiveField(0)
  String id;

  @HiveField(1)
  String time;

  Attendance(this.id, this.time);

  // Create a method to convert the object to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
    };
  }

  // Create a factory constructor to create a Recognition object from a Map
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      json['id'],
      json['time'],
    );
  }
}