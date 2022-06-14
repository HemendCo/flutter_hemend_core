import 'dart:convert';

import 'package:hive_flutter/adapters.dart';

part 'diet_model.g.dart';

@HiveType(typeId: 202)
class DietModel extends HiveObject {
  @HiveField(0)
  final String breakfast;
  @HiveField(1)
  final String snack;
  @HiveField(2)
  final String lunch;
  @HiveField(3)
  final String dinner;
  DietModel({
    required this.breakfast,
    required this.snack,
    required this.lunch,
    required this.dinner,
  });

  DietModel copyWith({
    String? breakfast,
    String? snack,
    String? lunch,
    String? dinner,
  }) {
    return DietModel(
      breakfast: breakfast ?? this.breakfast,
      snack: snack ?? this.snack,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'breakfast': breakfast,
      'snack': snack,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  factory DietModel.fromMap(Map<String, dynamic> map) {
    return DietModel(
      breakfast: map['breakfast'] ?? '',
      snack: map['snack'] ?? '',
      lunch: map['lunch'] ?? '',
      dinner: map['dinner'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DietModel.fromJson(String source) => DietModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DietModel(breakfast: $breakfast, snack: $snack, lunch: $lunch, dinner: $dinner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DietModel &&
        other.breakfast == breakfast &&
        other.snack == snack &&
        other.lunch == lunch &&
        other.dinner == dinner;
  }

  @override
  int get hashCode {
    return breakfast.hashCode ^ snack.hashCode ^ lunch.hashCode ^ dinner.hashCode;
  }
}
