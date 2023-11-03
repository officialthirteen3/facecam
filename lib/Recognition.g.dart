// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Recognition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecognitionAdapter extends TypeAdapter<Recognition> {
  @override
  final int typeId = 1;

  @override
  Recognition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recognition(
      fields[1] as String,
      fields[0] as String,
      fields[2] as String,
      (fields[3] as List).cast<double>(),
      fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Recognition obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.embeddings)
      ..writeByte(4)
      ..write(obj.distance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecognitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
