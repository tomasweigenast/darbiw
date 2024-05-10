import 'dart:typed_data';

import 'package:darbiw/binary.dart';
import 'package:test/test.dart';

void main() {
  group("Encode and decode", () {
    test("Encode two values", () {
      final buffer = BinaryWriter()
        ..writeDouble(25.6542)
        ..writeNull();

      final reader = BinaryReader(buffer.takeBytes());
      expect(reader.readDouble(), equals(25.6542));
      expect(reader.isNextNull(), isTrue);
    });

    test("Encode complex value", () {
      final buffer = BinaryWriter()
        ..writeDouble(25.6542)
        ..writeString("hello world")
        ..writeUint8List(Uint8List.fromList(<int>[25, 65, 42, 12, 122, 11]))
        ..writeNull()
        ..writeInt(25);

      final reader = BinaryReader(buffer.takeBytes());
      expect(reader.readDouble(), equals(25.6542));
      expect(reader.readString(), equals("hello world"));
      expect(reader.readUint8List(), equals(Uint8List.fromList(<int>[25, 65, 42, 12, 122, 11])));
      expect(reader.isNextNull(), isTrue);
      expect(reader.readInt(), 25);
    });
  });
}
