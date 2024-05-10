# darbiw

Dart binary encoder/decoder with code generation for classes

## Getting started

Tag your classes with the @binary annotation and add the `fromBuffer` factory constructor:

```dart
@binary
final class User {
  final String id;
  final int age;
  final bool enabled;
  final AccountType accountType;

  User({
    required this.id,
    required this.age,
    required this.enabled,
    required this.accountType,
  });

  factory User.fromBuffer(Uint8List buffer) => _UserFromBuffer(buffer);
}
```

Then run:

```
dart run build_runner build
```

and your binary methods will be generated.
