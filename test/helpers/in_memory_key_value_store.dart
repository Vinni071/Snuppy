import 'package:luminthor/core/storage/key_value_store.dart';

/// In-memory [KeyValueStore] for tests, with optional write failures.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object?> values;
  bool failWrites = false;
  int writes = 0;

  InMemoryKeyValueStore([Map<String, Object?>? initial])
      : values = {...?initial};

  @override
  bool get isAvailable => true;

  @override
  Object? read(String key) => values[key];

  @override
  Future<void> write(String key, Object? value) async {
    if (failWrites) throw StateError('disk full');
    writes++;
    values[key] = value;
  }
}
