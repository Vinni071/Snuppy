import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../domain/learning_path.dart';

class LearningProgress {
  final Set<String> completed;

  LearningProgress([Iterable<String> completed = const []])
      : completed = Set.unmodifiable(completed);

  bool isCompleted(LumiLesson lesson) => completed.contains(lesson.id);

  bool isUnlocked(LumiLesson lesson) {
    final index = LearningPath.lessons.indexOf(lesson);
    return index >= 0 &&
        (index == 0 || isCompleted(LearningPath.lessons[index - 1]));
  }

  LumiLesson? get nextLesson {
    for (final lesson in LearningPath.lessons) {
      if (!isCompleted(lesson)) return lesson;
    }
    return null;
  }

  int get xp => LearningPath.lessons
      .where(isCompleted)
      .fold(0, (total, lesson) => total + lesson.xp);

  int get completedModules => LearningPath.modules
      .where((module) => module.lessons.every(isCompleted))
      .length;

  double get fraction => completed.length / LearningPath.lessons.length;
}

class LearningNotifier extends Notifier<LearningProgress> {
  static const storageKey = 'lumi_learning_completed_v1';

  @override
  LearningProgress build() {
    if (!Hive.isBoxOpen('ide_box')) return LearningProgress();
    final saved = Hive.box('ide_box').get(storageKey);
    // Recover only a valid sequential prefix, ignoring obsolete or corrupt IDs.
    final completed = <String>[];
    if (saved is List) {
      for (final lesson in LearningPath.lessons) {
        if (!saved.contains(lesson.id)) break;
        completed.add(lesson.id);
      }
    }
    return LearningProgress(completed);
  }

  /// Returns false for locked lessons or incorrect answers; repeats earn no XP.
  Future<bool> submitAnswer(LumiLesson lesson, int answer) async {
    if (!state.isUnlocked(lesson) || answer != lesson.correctAnswer) {
      return false;
    }
    if (state.isCompleted(lesson)) return true;
    final updated = LearningProgress([...state.completed, lesson.id]);
    // Persist before awarding progress so a write failure can be retried.
    if (Hive.isBoxOpen('ide_box')) {
      try {
        await Hive.box('ide_box').put(storageKey, updated.completed.toList());
      } catch (error) {
        debugPrint('Não foi possível salvar a trilha Lumi: $error');
        rethrow;
      }
    }
    state = updated;
    return true;
  }
}

final learningProvider =
    NotifierProvider<LearningNotifier, LearningProgress>(LearningNotifier.new);
