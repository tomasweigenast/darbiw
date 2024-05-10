import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'spec.dart';

final _emptyList = Uint8List(0);

final class BinaryWriter {
  final _chunks = <Uint8List>[];
  final _offsets = <int>[];
  final int _capacity;
  Uint8List _currentChunk;
  int _offset = 0;
  int _length = 0;

  BinaryWriter([int initialCapacity = 2048])
      : _currentChunk = Uint8List(initialCapacity),
        _capacity = initialCapacity;

  int get length => _length;

  /// Writes a null value
  @pragma("vm:prefer-inline")
  void writeNull() => writeByte(kNullValue);

  /// Writes a single byte
  void writeByte(int byte) {
    _mayResize(1);
    _currentChunk[_offset++] = byte;
    _length++;
  }

  /// Writes a list of bytes
  void appendBytes(Uint8List bytes) {
    _mayResize(bytes.length);
    _currentChunk.setRange(_offset, _offset + bytes.length, bytes);
    _offset += bytes.length;
    _length += bytes.length;
  }

  /// Writes a buffer with its length
  @pragma("vm:prefer-inline")
  void writeUint8List(Uint8List buffer) {
    writeInt(buffer.length);
    appendBytes(buffer);
  }

  /// Writes a double value
  void writeDouble(double value) {
    _mayResize(8);
    _currentChunk.buffer.asByteData().setFloat64(_offset, value);
    _offset += 8;
    _length += 8;
  }

  /// Writes int value
  void writeInt(int value) {
    _mayResize(8);
    _currentChunk.buffer.asByteData().setInt64(_offset, value);
    _offset += 8;
    _length += 8;
  }

  /// Writes a string value
  @pragma("vm:prefer-inline")
  void writeString(String value) {
    final buffer = utf8.encode(value);
    writeInt(buffer.length);
    return appendBytes(buffer);
  }

  /// Builds the final buffer
  Uint8List takeBytes() {
    if (_length == 0) return _emptyList;
    if (_chunks.isEmpty) return Uint8List.view(_currentChunk.buffer, _currentChunk.offsetInBytes, _length);

    final buffer = Uint8List(_length);
    int offset = 0;
    for (int i = 0; i < _chunks.length; i++) {
      final chunk = _chunks[i];
      final chunkOffset = _offsets[i];

      buffer.setRange(offset, offset + chunkOffset, chunk);
      offset += chunkOffset;
    }

    if (_currentChunk.isNotEmpty) {
      buffer.setRange(offset, offset + _offset, _currentChunk);
    }

    _clear();
    return buffer;
  }

  @pragma("vm:prefer-inline")
  void _mayResize(int forSize) {
    if (_capacity - _offset < forSize) {
      _chunks.add(_currentChunk);
      _offsets.add(_offset);
      _currentChunk = Uint8List(max(_capacity, forSize) * 2);
      _offset = 0;
    }
  }

  void _clear() {
    _length = 0;
    _chunks.clear();
  }
}
