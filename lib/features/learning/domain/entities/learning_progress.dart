import 'package:luminthor/features/learning/domain/entities/learning_path.dart';

/// Immutable progress through [LearningPath], unlocked strictly in order.
class LearningProgress {
  final Set<String> completed;

  LearningProgress([Iterable<String> completed = const []])
      : completed = Set.unmodifiable(completed);

  /// Rebuilds progress from stored lesson IDs, keeping only the valid
  /// sequential prefix so obsolete or corrupt IDs cannot unlock later lessons.
  factory LearningProgress.restore(Iterable<Object?> storedIds) {
    final stored = storedIds.toSet();
    final completed = <String>[];
    for (final lesson in LearningPath.lessons) {
      if (!stored.contains(lesson.id)) break;
      completed.add(lesson.id);
    }
    return LearningProgress(completed);
  }

  bool isCompleted(LumiLesson lesson) => completed.contains(lesson.id);

  bool isUnlocked(LumiLesson lesson) {
    final index = LearningPath.lessons.indexOf(lesson);
    return index >= 0 &&
        (index == 0 || isCompleted(LearningPath.lessons[index - 1]));
  }

  /// Whether [answer] completes [lesson]: it must be unlocked and correct.
  bool accepts(LumiLesson lesson, int answer) =>
      isUnlocked(lesson) && answer == lesson.correctAnswer;

  /// Progress with [lesson] completed. Repeating a lesson changes nothing.
  LearningProgress complete(LumiLesson lesson) =>
      isCompleted(lesson) ? this : LearningProgress([...completed, lesson.id]);

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
