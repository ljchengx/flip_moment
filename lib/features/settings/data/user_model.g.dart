// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      nickname: fields[1] as String,
      level: fields[2] as int,
      totalFlips: fields[3] as int,
      currentExp: fields[4] as int,
      maxExpForNextLevel: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.totalFlips)
      ..writeByte(4)
      ..write(obj.currentExp)
      ..writeByte(5)
      ..write(obj.maxExpForNextLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
