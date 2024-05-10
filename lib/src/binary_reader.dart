import 'dart:convert';
import 'dart:typed_data';

import 'package:darbiw/src/spec.dart';

final class BinaryReader {
  final Uint8List _buffer;
  final ByteData _view;
  int _pos = 0;

  BinaryReader(Uint8List buffer)
      : _buffer = buffer,
        _view = ByteData.view(buffer.buffer);

  /// Checks if the next byte is the null byte. If so, advances one position and returns true,
  /// otherwise just return false.
  bool isNextNull() {
    if (_buffer[_pos] == kNullValue) {
      _pos++;
      return true;
    }

    return false;
  }

  /// Reads a single byte
  @pragma("vm:prefer-inline")
  int readByte() => _buffer[_pos++];

  /// Reads an int
  @pragma("vm:prefer-inline")
  int readInt() {
    int value = _view.getInt64(_pos);
    _pos += 8;
    return value;
  }

  /// Reads a double
  @pragma("vm:prefer-inline")
  double readDouble() {
    double value = _view.getFloat64(_pos);
    _pos += 8;
    return value;
  }

  /// Reads a boolean
  @pragma("vm:prefer-inline")
  bool readBool() => _buffer[_pos++] == 1;

  /// Reads an amount of bytes, without copying them.
  Uint8List readBytes(int count) {
    // final view = Uint8List.view(_buffer.buffer, _buffer.offsetInBytes + _pos, count);
    final view = _buffer.sublist(_pos, _pos + count);
    _pos += count;
    return view;
  }

  /// Reads a buffer value
  Uint8List readUint8List() {
    final size = readInt();
    return readBytes(size);
  }

  /// Reads a string
  String readString() {
    final size = readInt();
    final buffer = readBytes(size);
    return utf8.decode(buffer);
  }
}
