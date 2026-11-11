import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/features/learning/domain/entities/learning_progress.dart';
import 'package:luminthor/features/learning/domain/repositories/learning_progress_repository.dart';

class LocalLearningProgressRepository implements LearningProgressRepository {
  // Part of the persisted format; bump the suffix only with a migration.
  static const storageKey = 'lumi_learning_completed_v1';

  final KeyValueStore _store;

  const LocalLearningProgressRepository(this._store);

  @override
  LearningProgress load() {
    final saved = _store.read(storageKey);
    return saved is List ? LearningProgress.restore(saved) : LearningProgress();
  }

  @override
  Future<void> save(LearningProgress progress) =>
      _store.write(storageKey, progress.completed.toList());
}

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>(
  (ref) => LocalLearningProgressRepository(ref.watch(keyValueStoreProvider)),
);
