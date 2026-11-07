import 'package:go_router/go_router.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/learning/presentation/lesson_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/editor',
        name: 'editor',
        builder: (context, state) => EditorScreen(
          fromLearning: state.uri.queryParameters['from'] == 'learn',
        ),
      ),
      GoRoute(
        path: '/learn',
        name: 'learning',
        builder: (context, state) =>
            const HomeScreen(initialSection: HomeScreen.learningSection),
      ),
      GoRoute(
        path: '/learn/lesson/:lessonId',
        name: 'lesson',
        builder: (context, state) => LessonScreen(
          key: state.pageKey,
          lessonId: state.pathParameters['lessonId']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
