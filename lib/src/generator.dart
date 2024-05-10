import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:darbiw/darbiw.dart';
import 'package:source_gen/source_gen.dart';

final _datetimeChecker = TypeChecker.fromRuntime(DateTime);
final _durationChecker = TypeChecker.fromRuntime(Duration);

final class BinaryGenerator extends GeneratorForAnnotation<Binary> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final encoderBuffer = StringBuffer();
    final decoderBuffer = StringBuffer();
    if (element is! ClassElement) {
      throw "Binary annotation must be only added to classes.";
    }

    final constructor = element.constructors
        .where((element) => element.name.isEmpty)
        .firstOrNull;
    if (constructor == null) {
      print(
          "ignoring ${element.name} because not default constructor is found.");
      return "";
    }

    // fields are sorted
    final fields = constructor.parameters.toList();
    fields.sort((a, b) => a.name.compareTo(b.name));

    // iterate over parameters
    int bufferSize = 0;
    final encoders = <String>[];
    final decoders = <String>[];
    for (final parameter in constructor.parameters) {
      final (writer, size) =
          _getNullabilityWriter(parameter.name, parameter.type);
      bufferSize += size;
      encoders.add(writer);

      final decoder = _getNullabilityReader(parameter.type);
      decoders.add("${parameter.name}: $decoder,");
    }

    // Write encoder mixin
    encoderBuffer.write("""extension ${element.name}Binary on ${element.name} {
      Uint8List toBuffer() {
        final writer = BinaryWriter($bufferSize);
        """);
    encoderBuffer.writeAll(encoders);
    encoderBuffer.write(
        "return writer.takeBytes(); }}"); // end of toBuffer. end of extension declx

    // write XFromBuffer method
    decoderBuffer.write('@pragma("vm:prefer-inline")');
    decoderBuffer
        .write("""${element.name} _${element.name}FromBuffer(Uint8List buffer) {
      final reader = BinaryReader(buffer);
      return ${element.name}(""");
    decoderBuffer.writeAll(decoders);
    decoderBuffer
        .write("); }"); // end of constructor - end of XFromBuffer method

    return encoderBuffer.toString() + decoderBuffer.toString();
  }
}

(String writer, int bufferSize) _getNullabilityWriter(
    String paramName, DartType type) {
  final bool isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
  var (writer, bufferSize) = _getWriter(paramName, type, isNullable);

  if (isNullable) {
    writer = "if($paramName == null) { writer.writeNull(); } else { $writer }";
  }

  return (writer, bufferSize);
}

(String writer, int bufferSize) _getWriter(String paramName, DartType type,
    [bool isNullable = false]) {
  if (type.isDartCoreBool) {
    return ("writer.writeByte($paramName ? 1 : 0);", 1);
  } else if (type.isDartCoreDouble) {
    return ("writer.writeDouble($paramName);", 8);
  } else if (type.isDartCoreInt) {
    return ("writer.writeInt($paramName);", 8);
  } else if (type.isDartCoreNum) {
    return (
      "$paramName is int ? writer.writeInt($paramName) : writer.writeDouble($paramName);",
      8
    );
  } else if (type.isDartCoreString) {
    return ("writer.writeString($paramName);", 300);
  } else if (type.isDartCoreList || type.isDartCoreSet) {
    // get base type
    final baseType = (type as ParameterizedType).typeArguments.first;
    final baseTypeIsNullable =
        baseType.nullabilitySuffix == NullabilitySuffix.question;
    var (baseTypeWriter, size) = _getWriter(
        "$paramName${isNullable ? '!' : ''}[i]${baseTypeIsNullable ? '!' : ''}",
        baseType);
    if (baseTypeIsNullable) {
      baseTypeWriter =
          "$paramName${isNullable ? '!' : ''}[i] == null ? writer.writeNull() : $baseTypeWriter";
    }

    return (
      """
writer.writeInt($paramName${isNullable ? '!' : ''}.length);
for(int i = 0; i < $paramName${isNullable ? '!' : ''}.length; i++) {
  $baseTypeWriter
}
""",
      size * 5
    );
  } else if (type.isDartCoreMap) {
    // get base types
    final args = (type as ParameterizedType).typeArguments;
    final keyType = args.first;
    if (keyType.nullabilitySuffix == NullabilitySuffix.question) {
      throw "[$paramName]: Map types cannot define nullable keys.";
    }

    final valueType = args.last;
    final (keyTypeWriter, keySize) = _getWriter("key", keyType);
    var (valueTypeWriter, valueSize) = _getWriter("value", valueType);

    if (valueType.nullabilitySuffix == NullabilitySuffix.question) {
      valueTypeWriter = "value == null ? writer.writeNull() : $valueTypeWriter";
    }

    return (
      """
writer.writeInt($paramName${isNullable ? '!' : ''}.length);
for(final MapEntry(:key, :value) in $paramName${isNullable ? '!' : ''}.entries) {
  $keyTypeWriter
  $valueTypeWriter
}
""",
      (keySize + valueSize) * 5
    );
  } else if (type is InterfaceType) {
    if (type.element is EnumElement) {
      // bufferSize += 1; // maybe increase this for bigger enums
      return ("writer.writeByte($paramName${isNullable ? '!' : ''}.index);", 1);
    } else if (type.element is ClassElement) {
      if (_datetimeChecker.isAssignableFrom(type.element)) {
        return ("writer.writeInt($paramName.millisecondsSinceEpoch);", 8);
      } else if (_durationChecker.isAssignableFrom(type.element)) {
        return ("writer.writeInt($paramName.inMilliseconds);", 8);
      }
      return (
        "writer.writeUint8List($paramName${isNullable ? '!' : ''}.toBuffer());",
        512
      );
    }
  }

  throw "Parameter $paramName with type $type is not supported.";
}

String _getNullabilityReader(DartType type) {
  var reader = _getReader(type);
  if (type.nullabilitySuffix == NullabilitySuffix.question) {
    reader = "reader.isNextNull() ? null : $reader";
  }
  return reader;
}

String _getReader(DartType type) {
  if (type.isDartCoreBool) {
    return "reader.readBool()";
  } else if (type.isDartCoreDouble) {
    return "reader.readDouble()";
  } else if (type.isDartCoreInt) {
    return "reader.readInt()";
  } else if (type.isDartCoreNum) {
    return "reader.readInt() as num";
  } else if (type.isDartCoreString) {
    return "reader.readString()";
  } else if (type.isDartCoreList || type.isDartCoreSet) {
    // get base type
    final baseType = (type as ParameterizedType).typeArguments.first;
    final valueReader = _getNullabilityReader(baseType);

    return "List.generate(reader.readInt(), (_) => $valueReader)";
  } else if (type.isDartCoreMap) {
    // get base types
    final args = (type as ParameterizedType).typeArguments;
    final keyType = args.first;
    final valueType = args.last;

    final keyReader = _getReader(keyType);
    final valueReader = _getNullabilityReader(valueType);

    return "Map.fromEntries(Iterable.generate(reader.readInt(), (_) => MapEntry($keyReader, $valueReader)))";
  } else if (type is InterfaceType) {
    if (type.element is EnumElement) {
      return "${type.getDisplayString(withNullability: false)}.values[reader.readByte()]";
    } else if (type.element is ClassElement) {
      if (_datetimeChecker.isAssignableFrom(type.element)) {
        return "${type.getDisplayString(withNullability: false)}.fromMillisecondsSinceEpoch(reader.readInt())";
      } else if (_durationChecker.isAssignableFrom(type.element)) {
        return "${type.getDisplayString(withNullability: false)}(milliseconds: reader.readInt())";
      }
      return "${type.getDisplayString(withNullability: false)}.fromBuffer(reader.readUint8List())";
    }
  }

  throw "Type $type is not supported.";
}
