import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/src/rust/errors.dart';

/// Runs Lumi source through the full pipeline (lexer → parser → semantic
/// analysis → interpreter).
///
/// The FFI-generated types ([CompileResult] and friends) are already immutable
/// Dart value classes, so they are used as the shared model instead of being
/// duplicated into parallel domain entities.
typedef SourceCompiler = Future<CompileResult> Function(String source);

/// Result shown when the engine itself could not be reached, as opposed to a
/// program that failed to compile or run.
CompileResult engineUnavailableResult() => const CompileResult(
      tokens: [],
      output: '',
      errors: [
        CompileError.runtimeError(
          message: 'Não foi possível executar o programa porque a comunicação '
              'com a engine Lumi falhou. Feche e abra o aplicativo novamente. '
              'Se o problema continuar, recompile o aplicativo para atualizar '
              'a biblioteca Rust.',
          callStack: [],
        ),
      ],
      memoryState: {},
      executionTrace: [],
      warnings: [],
      success: false,
    );
