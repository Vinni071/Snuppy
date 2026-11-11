import 'package:luminthor/features/learning/domain/entities/learning_progress.dart';

abstract interface class LearningProgressRepository {
  LearningProgress load();

  /// Persists [progress]; failures are propagated so the caller can retry.
  Future<void> save(LearningProgress progress);
}
