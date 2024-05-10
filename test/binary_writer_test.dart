import 'dart:typed_data';

import 'package:darbiw/src/binary_writer.dart';
import 'package:test/test.dart';

void main() {
  group("BinaryWriter tests", () {
    test("empty buffer returns empty list", () {
      final writer = BinaryWriter();
      expect(writer.takeBytes(), equals(Uint8List(0)));
    });

    test("without chunking", () {
      final writer = BinaryWriter();
      writer.writeUint8List(
          Uint8List.fromList(<int>[12, 54, 32, 12, 77, 98, 211, 1]));

      expect(
          writer.takeBytes(),
          equals(Uint8List(8)
            ..setRange(0, 8, <int>[12, 54, 32, 12, 77, 98, 211, 1])));
    });

    test("chunking", () {
      final writer = BinaryWriter(2);
      writer.writeUint8List(Uint8List.fromList(<int>[12, 54, 32, 12]));
      writer.writeByte(5);
      writer.writeByte(8);
      writer.writeByte(241);
      expect(writer.takeBytes(),
          equals(Uint8List.fromList(<int>[12, 54, 32, 12, 5, 8, 241])));
    });

    test("chunking without filling up chunk", () {
      final writer = BinaryWriter(5);
      writer.writeUint8List(Uint8List.fromList(<int>[12, 54]));
      writer
          .writeUint8List(Uint8List.fromList(<int>[12, 54, 65, 87, 12, 2, 3]));
      expect(writer.takeBytes(),
          equals(Uint8List.fromList(<int>[12, 54, 12, 54, 65, 87, 12, 2, 3])));
    });
  });
}
