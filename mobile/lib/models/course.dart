import 'package:flutter/material.dart';

class Course {
  const Course({
    required this.id,
    required this.name,
    this.code,
    this.colorHex,
    this.emoji,
    this.courseType,
  });

  final String id;
  final String name;
  final String? code;
  final String? colorHex;
  final String? emoji;
  final String? courseType; // calculation | concept | skill | mixed

  Color get colorValue {
    if (colorHex == null) return const Color(0xFF6C5CE7);
    final hex = colorHex!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String?,
        colorHex: json['color_hex'] as String?,
        emoji: json['emoji'] as String?,
        courseType: json['course_type'] as String?,
      );

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        if (code != null) 'code': code,
        if (colorHex != null) 'colorHex': colorHex,
        if (emoji != null) 'emoji': emoji,
        if (courseType != null) 'courseType': courseType,
      };
}
