import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/features/learning/data/repositories/local_learning_progress_repository.dart';
import 'package:luminthor/features/learning/domain/entities/learning_path.dart';
import 'package:luminthor/features/learning/domain/entities/learning_progress.dart';

export 'package:luminthor/features/learning/domain/entities/learning_progress.dart';

class LearningNotifier extends Notifier<LearningProgress> {
  @override
  LearningProgress build() =>
      ref.watch(learningProgressRepositoryProvider).load();

  /// Returns false for locked lessons or incorrect answers; repeats earn no XP.
  ///
  /// Throws when progress cannot be saved, leaving the state unchanged so the
  /// learner can retry.
  Future<bool> submitAnswer(LumiLesson lesson, int answer) async {
    if (!state.accepts(lesson, answer)) return false;
    if (state.isCompleted(lesson)) return true;
    final updated = state.complete(lesson);
    // Persist before awarding progress so a write failure can be retried.
    try {
      await ref.read(learningProgressRepositoryProvider).save(updated);
    } catch (error, stack) {
      reportError('Não foi possível salvar a trilha Lumi', error, stack);
      rethrow;
    }
    state = updated;
    return true;
  }
}

final learningProvider =
    NotifierProvider<LearningNotifier, LearningProgress>(LearningNotifier.new);
