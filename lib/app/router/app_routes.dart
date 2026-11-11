/// Route paths and typed location builders.
///
/// Screens navigate through these helpers instead of hand-written strings, so
/// renaming a path or a parameter happens in one place.
abstract final class AppRoutes {
  static const home = '/';
  static const editor = '/editor';
  static const learning = '/learn';
  static const lesson = '/learn/lesson/:lessonId';
  static const settings = '/settings';

  static const lessonIdParam = 'lessonId';
  static const _fromParam = 'from';
  static const _fromLearningValue = 'learn';

  /// Editor location; [fromLearning] makes "back" return to the lesson.
  static String editorLocation({bool fromLearning = false}) => fromLearning
      ? Uri(path: editor, queryParameters: {_fromParam: _fromLearningValue})
          .toString()
      : editor;

  static bool isFromLearning(Uri uri) =>
      uri.queryParameters[_fromParam] == _fromLearningValue;

  static String lessonLocation(String lessonId) =>
      '$learning/lesson/${Uri.encodeComponent(lessonId)}';
}
