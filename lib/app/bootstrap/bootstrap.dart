import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:luminthor/core/compiler/engine_library_path.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/src/rust/frb_generated.dart';

/// Opens local storage. Returns a user-facing error message on failure.
///
/// Runs before [runApp] because every repository reads synchronously from the
/// opened box while building its initial state.
Future<String?> initializeStorage() async {
  try {
    await HiveKeyValueStore.open();
    return null;
  } catch (error, stack) {
    reportError('Hive initialization failed', error, stack);
    return 'Erro de persistencia (Hive): $error';
  }
}

/// Loads the Rust engine through FFI while the splash screen plays.
///
/// Resolves to the first initialization error to show, if any.
Future<String?> initializeEngine(String? persistenceError) async {
  try {
    final libraryPath = bundledEngineLibraryPath();
    await RustLib.init(
      externalLibrary:
          libraryPath == null ? null : ExternalLibrary.open(libraryPath),
    );
    return persistenceError;
  } catch (error, stack) {
    reportError('RustLib FFI initialization failed', error, stack);
    return 'Erro de FFI (Rust Core): $error\n\n'
        'Certifique-se de ter compilado o Rust executando "cargo build" '
        'na pasta "rust_core" antes de rodar o Flutter.';
  }
}
