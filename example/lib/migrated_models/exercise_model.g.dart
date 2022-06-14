// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 201;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseModel(
      quantity: fields[0] as int,
      type: fields[1] as ExerciseExecutionType,
      name: fields[2] as String,
      kcal: fields[3] as double,
      duration: fields[4] as double,
      description: fields[5] as String,
      gifName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.quantity)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.kcal)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.gifName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseExecutionTypeAdapter extends TypeAdapter<ExerciseExecutionType> {
  @override
  final int typeId = 210;

  @override
  ExerciseExecutionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseExecutionType.unit;
      case 1:
        return ExerciseExecutionType.time;
      default:
        return ExerciseExecutionType.unit;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseExecutionType obj) {
    switch (obj) {
      case ExerciseExecutionType.unit:
        writer.writeByte(0);
        break;
      case ExerciseExecutionType.time:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseExecutionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
