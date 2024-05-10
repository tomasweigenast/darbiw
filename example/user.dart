import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:darbiw/darbiw.dart';

part 'user.g.dart';

@binary
final class User {
  final String id;
  final int age;
  final bool enabled;
  final AccountType accountType;
  final String? name;
  final List<int> flags;
  final Map<String, bool> follows;
  final List<int?>? arguments;
  final Address? address;
  final Map<String, double?>? amounts;
  final DateTime createdAt;
  final Duration ttl;

  User({
    required this.id,
    required this.age,
    required this.name,
    required this.enabled,
    required this.accountType,
    required this.flags,
    required this.follows,
    required this.address,
    required this.arguments,
    required this.amounts,
    required this.createdAt,
    required this.ttl,
  });

  factory User.fromBuffer(Uint8List buffer) => _UserFromBuffer(buffer);

  @override
  int get hashCode => Object.hash(id, age, enabled, accountType, flags, follows,
      arguments, address, amounts, createdAt, ttl, name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other.age == age &&
          other.enabled == enabled &&
          other.accountType == accountType &&
          const ListEquality().equals(other.flags, flags) &&
          const MapEquality().equals(other.follows, follows) &&
          const ListEquality().equals(other.arguments, arguments) &&
          other.address == address &&
          const MapEquality().equals(other.amounts, amounts) &&
          other.ttl == ttl &&
          other.createdAt == createdAt &&
          other.name == name);
}

enum AccountType { unknown, customer, admin }

@binary
final class Address {
  final String name;
  final Coordinates location;

  Address({required this.name, required this.location});

  factory Address.fromBuffer(Uint8List buffer) => _AddressFromBuffer(buffer);

  @override
  int get hashCode => Object.hash(name, location);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Address && other.name == name && other.location == location);
}

@binary
final class Coordinates {
  final double latitude, longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromBuffer(Uint8List buffer) =>
      _CoordinatesFromBuffer(buffer);

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is Coordinates &&
          other.latitude == latitude &&
          other.longitude == longitude);
}
