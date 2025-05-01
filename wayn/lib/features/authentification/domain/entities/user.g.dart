// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      email: fields[1] as String?,
      phoneNumber: fields[2] as String,
      firstName: fields[3] as String,
      lastName: fields[4] as String,
      sexe: fields[5] as String,
      choices: (fields[6] as List?)?.cast<String>() ??
          [], // Ajout de la vérification null
      firebaseToken: fields[10] as String,
      stripeId: fields[11] as String,
      carPreferences: (fields[13] as List?)?.cast<String>(),
      createdAt: fields[7] as String?,
      preferedDepart: fields[8] as String?,
      preferedArrival: fields[9] as String?,
      roles: (fields[12] as List?)?.cast<String>() ??
          [], // Ajout de la vérification null
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName)
      ..writeByte(5)
      ..write(obj.sexe)
      ..writeByte(6)
      ..write(obj.choices)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.preferedDepart)
      ..writeByte(9)
      ..write(obj.preferedArrival)
      ..writeByte(10)
      ..write(obj.firebaseToken)
      ..writeByte(11)
      ..write(obj.stripeId)
      ..writeByte(12)
      ..write(obj.roles)
      ..writeByte(13)
      ..write(obj.carPreferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
