import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Minimal persistence contract shared by the feature repositories.
///
/// Repositories depend on this interface instead of Hive, so storage can be
/// replaced (or faked in tests) without touching domain or presentation code.
abstract interface class KeyValueStore {
  /// Whether the underlying storage is ready to be used.
  bool get isAvailable;

  Object? read(String key);

  /// Persists [value]. Failures are propagated to the caller.
  Future<void> write(String key, Object? value);
}

/// [KeyValueStore] backed by the single Hive box used by the app.
///
/// The box name is part of the on-disk format: changing it would orphan the
/// data already saved on users' devices.
class HiveKeyValueStore implements KeyValueStore {
  static const boxName = 'ide_box';

  const HiveKeyValueStore();

  /// Initializes Hive and opens the app box. Must run before [runApp].
  static Future<void> open() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  @override
  bool get isAvailable => Hive.isBoxOpen(boxName);

  @override
  Object? read(String key) => isAvailable ? Hive.box(boxName).get(key) : null;

  @override
  Future<void> write(String key, Object? value) async {
    if (!isAvailable) return;
    await Hive.box(boxName).put(key, value);
  }
}

final keyValueStoreProvider =
    Provider<KeyValueStore>((ref) => const HiveKeyValueStore());
