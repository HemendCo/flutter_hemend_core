import 'dart:convert';

import 'package:hemend/debug/error_handler.dart';
import 'package:hemend/extensions/map_verification_tools.dart';
import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class ExerciseModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int dayId;
  @HiveField(2)
  final int exerciseId;
  @HiveField(3)
  final int quantity;
  @HiveField(4)
  final ExerciseType type;
  ExerciseModel({
    required this.id,
    required this.dayId,
    required this.exerciseId,
    required this.quantity,
    required this.type,
  });

  ExerciseModel copyWith({
    int? id,
    int? dayId,
    int? exerciseId,
    int? quantity,
    ExerciseType? type,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      exerciseId: exerciseId ?? this.exerciseId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      //  'id', 'id_day', 'id_exercise', 'quantity', 'type'
      'id': id,
      'id_day': dayId,
      'id_exercise': exerciseId,
      'quantity': quantity,
      'type': type.name,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    map.breakOnMissingKey(['id', 'id_day', 'id_exercise', 'quantity', 'type']);
    return ExerciseModel(
      //  'id', 'id_day', 'id_exercise', 'quantity', 'type'
      id: _toInt(map['id']),
      dayId: _toInt(map['id_day']),
      exerciseId: _toInt(map['id_exercise']),
      quantity: _toInt(map['quantity']),
      type: ExerciseType.fromString(map['type']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseModel.fromJson(String source) => ExerciseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ExerciseModel(id: $id, dayId: $dayId, exerciseId: $exerciseId, quantity: $quantity, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseModel &&
        other.id == id &&
        other.dayId == dayId &&
        other.exerciseId == exerciseId &&
        other.quantity == quantity &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^ dayId.hashCode ^ exerciseId.hashCode ^ quantity.hashCode ^ type.hashCode;
  }
}

int _toInt(String value) {
  final result = int.tryParse(value);
  if (result == null) {
    throw ErrorHandler(
      'Given String $value cannot be casted to int',
      {
        ErrorType.typeError,
      },
    );
  }
  return result;
}

@HiveType(typeId: 100)
enum ExerciseType {
  @HiveField(0)
  unit,
  @HiveField(1)
  time;

  const ExerciseType();
  factory ExerciseType.fromString(String value) {
    return ExerciseType.values.firstWhere((element) => element.name == value);
  }
}
