import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/features/learning/data/repositories/local_learning_progress_repository.dart';
import 'package:luminthor/features/learning/domain/entities/learning_path.dart';
import 'package:luminthor/features/learning/presentation/viewmodels/learning_view_model.dart';

import '../helpers/in_memory_key_value_store.dart';

void main() {
  final lessons = LearningPath.lessons;

  group('LearningProgress', () {
    test('restore keeps only the valid sequential prefix', () {
      final progress = LearningProgress.restore(
          [lessons[0].id, lessons[2].id, 42, null, 'obsoleta']);
      expect(progress.completed, {lessons[0].id});
      expect(progress.isUnlocked(lessons[1]), isTrue);
      expect(progress.isUnlocked(lessons[2]), isFalse);
    });

    test('accepts only correct answers to unlocked lessons', () {
      final progress = LearningProgress();
      final first = lessons[0];
      expect(progress.accepts(first, first.correctAnswer), isTrue);
      expect(progress.accepts(first, first.correctAnswer + 1), isFalse);
      expect(progress.accepts(lessons[1], lessons[1].correctAnswer), isFalse);
    });

    test('completing twice is idempotent and XP is not duplicated', () {
      final once = LearningProgress().complete(lessons[0]);
      final twice = once.complete(lessons[0]);
      expect(identical(once, twice), isTrue);
      expect(twice.xp, lessons[0].xp);
      expect(twice.nextLesson, lessons[1]);
    });
  });

  group('LearningNotifier', () {
    test('persists progress through the repository', () async {
      final store = InMemoryKeyValueStore();
      final container = ProviderContainer(
          overrides: [keyValueStoreProvider.overrideWithValue(store)]);
      addTearDown(container.dispose);

      final first = lessons[0];
      expect(
          await container
              .read(learningProvider.notifier)
              .submitAnswer(first, first.correctAnswer),
          isTrue);
      expect(
          store.values[LocalLearningProgressRepository.storageKey], [first.id]);
    });

    test('a failed save throws and does not award progress', () async {
      final store = InMemoryKeyValueStore()..failWrites = true;
      final container = ProviderContainer(
          overrides: [keyValueStoreProvider.overrideWithValue(store)]);
      addTearDown(container.dispose);

      final first = lessons[0];
      await expectLater(
          container
              .read(learningProvider.notifier)
              .submitAnswer(first, first.correctAnswer),
          throwsStateError);
      expect(container.read(learningProvider).completed, isEmpty);

      // Retrying after the storage recovers succeeds.
      store.failWrites = false;
      expect(
          await container
              .read(learningProvider.notifier)
              .submitAnswer(first, first.correctAnswer),
          isTrue);
      expect(container.read(learningProvider).xp, first.xp);
    });
  });
}
