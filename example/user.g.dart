// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'user.dart';

// **************************************************************************
// BinaryGenerator
// **************************************************************************

extension UserBinary on User {
  Uint8List toBuffer() {
    final writer = BinaryWriter(3947);
    writer.writeString(id);
    writer.writeInt(age);
    writer.writeByte(enabled ? 1 : 0);
    writer.writeByte(accountType.index);
    writer.writeInt(flags.length);
    for (int i = 0; i < flags.length; i++) {
      writer.writeInt(flags[i]);
    }
    writer.writeInt(follows.length);
    for (final MapEntry(:key, :value) in follows.entries) {
      writer.writeString(key);
      writer.writeByte(value ? 1 : 0);
    }
    if (address == null) {
      writer.writeNull();
    } else {
      writer.writeUint8List(address!.toBuffer());
    }
    if (arguments == null) {
      writer.writeNull();
    } else {
      writer.writeInt(arguments!.length);
      for (int i = 0; i < arguments!.length; i++) {
        arguments![i] == null
            ? writer.writeNull()
            : writer.writeInt(arguments![i]!);
      }
    }
    if (amounts == null) {
      writer.writeNull();
    } else {
      writer.writeInt(amounts!.length);
      for (final MapEntry(:key, :value) in amounts!.entries) {
        writer.writeString(key);
        value == null ? writer.writeNull() : writer.writeDouble(value);
      }
    }
    return writer.takeBytes();
  }
}

@pragma("vm:prefer-inline")
User _UserFromBuffer(Uint8List buffer) {
  final reader = BinaryReader(buffer);
  return User(
    id: reader.readString(),
    age: reader.readInt(),
    enabled: reader.readBool(),
    accountType: AccountType.values[reader.readByte()],
    flags: List.generate(reader.readInt(), (_) => reader.readInt()),
    follows: Map.fromEntries(Iterable.generate(reader.readInt(),
        (_) => MapEntry(reader.readString(), reader.readBool()))),
    address:
        reader.isNextNull() ? null : Address.fromBuffer(reader.readUint8List()),
    arguments: reader.isNextNull()
        ? null
        : List.generate(reader.readInt(),
            (_) => reader.isNextNull() ? null : reader.readInt()),
    amounts: reader.isNextNull()
        ? null
        : Map.fromEntries(Iterable.generate(
            reader.readInt(),
            (_) => MapEntry(reader.readString(),
                reader.isNextNull() ? null : reader.readDouble()))),
  );
}

extension AddressBinary on Address {
  Uint8List toBuffer() {
    final writer = BinaryWriter(812);
    writer.writeString(name);
    writer.writeUint8List(location.toBuffer());
    return writer.takeBytes();
  }
}

@pragma("vm:prefer-inline")
Address _AddressFromBuffer(Uint8List buffer) {
  final reader = BinaryReader(buffer);
  return Address(
    name: reader.readString(),
    location: Coordinates.fromBuffer(reader.readUint8List()),
  );
}

extension CoordinatesBinary on Coordinates {
  Uint8List toBuffer() {
    final writer = BinaryWriter(16);
    writer.writeDouble(latitude);
    writer.writeDouble(longitude);
    return writer.takeBytes();
  }
}

@pragma("vm:prefer-inline")
Coordinates _CoordinatesFromBuffer(Uint8List buffer) {
  final reader = BinaryReader(buffer);
  return Coordinates(
    latitude: reader.readDouble(),
    longitude: reader.readDouble(),
  );
}
