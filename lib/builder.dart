/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:build/build.dart';
import 'package:darbiw/src/generator.dart';
import 'package:source_gen/source_gen.dart';

SharedPartBuilder generator(BuilderOptions options) => SharedPartBuilder(
      [BinaryGenerator()],
      "binary",
    );
