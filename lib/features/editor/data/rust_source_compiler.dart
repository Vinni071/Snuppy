import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/features/editor/domain/source_compiler.dart';
import 'package:luminthor/src/rust/api.dart';

/// Binds [SourceCompiler] to the Rust engine loaded through FFI.
final sourceCompilerProvider = Provider<SourceCompiler>(
  (ref) => (source) => processSource(source: source),
);
