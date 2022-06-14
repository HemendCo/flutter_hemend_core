// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DietModelAdapter extends TypeAdapter<DietModel> {
  @override
  final int typeId = 202;

  @override
  DietModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DietModel(
      breakfast: fields[0] as String,
      snack: fields[1] as String,
      lunch: fields[2] as String,
      dinner: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DietModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.breakfast)
      ..writeByte(1)
      ..write(obj.snack)
      ..writeByte(2)
      ..write(obj.lunch)
      ..writeByte(3)
      ..write(obj.dinner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
