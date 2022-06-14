import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'diet_model.dart';
import 'exercise_model.dart';

part 'exercise_day_model.g.dart';

@HiveType(typeId: 200)
class ExerciseDayModel extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<ExerciseModel> exercises;
  @HiveField(2)
  final DietModel diet;

  bool get hasExercise => exercises.isEmpty;
  ExerciseDayModel({
    required this.name,
    required this.exercises,
    required this.diet,
  });

  ExerciseDayModel copyWith({
    String? name,
    List<ExerciseModel>? exercises,
    DietModel? diet,
  }) {
    return ExerciseDayModel(
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      diet: diet ?? this.diet,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((x) => x.toMap()).toList(),
      'diet': diet.toMap(),
    };
  }

  factory ExerciseDayModel.fromMap(Map<String, dynamic> map) {
    return ExerciseDayModel(
      name: map['name'] ?? '',
      exercises: List<ExerciseModel>.from(map['exercises']?.map((x) => ExerciseModel.fromMap(x))),
      diet: DietModel.fromMap(map['diet']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseDayModel.fromJson(String source) => ExerciseDayModel.fromMap(json.decode(source));

  @override
  String toString() => 'ExerciseDayModel(name: $name, exercises: $exercises, diet: $diet)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseDayModel &&
        other.name == name &&
        listEquals(other.exercises, exercises) &&
        other.diet == diet;
  }

  @override
  int get hashCode => name.hashCode ^ exercises.hashCode ^ diet.hashCode;
}
