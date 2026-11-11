import 'package:go_router/go_router.dart';
import 'package:luminthor/app/router/app_routes.dart';
import 'package:luminthor/features/editor/presentation/screens/editor_screen.dart';
import 'package:luminthor/features/home/presentation/screens/home_screen.dart';
import 'package:luminthor/features/learning/presentation/screens/lesson_screen.dart';
import 'package:luminthor/features/settings/presentation/screens/settings_screen.dart';

export 'package:luminthor/app/router/app_routes.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    // Unknown or malformed locations (e.g. stale deep links) fall back to Home
    // instead of showing GoRouter's raw error page.
    onException: (context, state, router) => router.go(AppRoutes.home),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.editor,
        name: 'editor',
        builder: (context, state) => EditorScreen(
          fromLearning: AppRoutes.isFromLearning(state.uri),
        ),
      ),
      GoRoute(
        path: AppRoutes.learning,
        name: 'learning',
        builder: (context, state) =>
            const HomeScreen(initialSection: HomeSection.learning),
      ),
      GoRoute(
        path: AppRoutes.lesson,
        name: 'lesson',
        builder: (context, state) => LessonScreen(
          key: state.pageKey,
          lessonId: state.pathParameters[AppRoutes.lessonIdParam]!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
