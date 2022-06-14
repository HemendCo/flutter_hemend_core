// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_day_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseDayModelAdapter extends TypeAdapter<ExerciseDayModel> {
  @override
  final int typeId = 200;

  @override
  ExerciseDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseDayModel(
      name: fields[0] as String,
      exercises: (fields[1] as List).cast<ExerciseModel>(),
      diet: fields[2] as DietModel,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseDayModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises)
      ..writeByte(2)
      ..write(obj.diet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
