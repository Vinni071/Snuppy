import 'package:flutter/foundation.dart';

/// Single place where unexpected failures are logged for diagnosis.
///
/// Only technical context is logged; user content (source code, file
/// contents) must never be passed as [context].
void reportError(String context, Object error, [StackTrace? stack]) {
  debugPrint('$context: $error${stack == null ? '' : '\n$stack'}');
}
