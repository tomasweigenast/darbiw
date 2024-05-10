import 'user.dart';

void main() {
  final user = User(
    id: "12345",
    accountType: AccountType.customer,
    age: 15,
    enabled: true,
    arguments: null,
    amounts: {
      "a": 12.5,
      "b": null,
      "c": null,
      "d": 3333.3322145,
      "e": null,
    },
    flags: [12, 24, 22],
    follows: {
      "userA": true,
      "userB": true,
      "userC": true,
      "userD": true,
    },
    address: Address(
      name: "Street Name",
      location: Coordinates(
        latitude: -24.2244,
        longitude: 124.545,
      ),
    ),
  );

  final buffer = user.toBuffer();
  final userB = User.fromBuffer(buffer);

  print(user == userB);
}
