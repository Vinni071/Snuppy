import 'dart:io';

/// Use the library built with the Linux app, even when a project checkout
/// contains an older release library.
String? bundledEngineLibraryPath({String? executablePath}) {
  if (!Platform.isLinux) return null;
  final executable =
      File(executablePath ?? Platform.resolvedExecutable).absolute;
  final library = File('${executable.parent.path}/lib/libide_engine.so');
  return library.existsSync() ? library.path : null;
}
