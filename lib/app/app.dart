import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/app/bootstrap/initialization_error_screen.dart';
import 'package:luminthor/app/router/app_router.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luminthor/features/splash/presentation/screens/splash_screen.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

export 'package:luminthor/app/bootstrap/initialization_error_screen.dart';

/// Root widget: plays the splash while the engine loads, then shows either the
/// router or the initialization error.
class MyApp extends ConsumerStatefulWidget {
  final String? error;
  final Future<String?>? initialization;
  final bool showSplash;

  const MyApp({
    super.key,
    this.error,
    this.initialization,
    this.showSplash = true,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static const _title = 'Luminthor — Compilador Didático';

  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  late bool _introComplete;
  late bool _initializationReady;
  String? _error;

  @override
  void initState() {
    super.initState();
    _introComplete = !widget.showSplash;
    _initializationReady = widget.initialization == null;
    _error = widget.error;
    if (widget.initialization != null) _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    String? error;
    try {
      error = await widget.initialization;
    } catch (exception) {
      error = 'Não foi possível inicializar o Luminthor: $exception';
    }
    if (!mounted) return;
    setState(() {
      _error = error ?? widget.error;
      _initializationReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only the theme mode matters here; font size changes must not rebuild
    // the whole MaterialApp.
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    ref.listen<bool>(workspaceSaveFailedProvider, _showSaveStatus);

    if (!_introComplete || !_initializationReady) {
      return _materialApp(
        themeMode,
        home: SplashScreen(
          initializationReady: _initializationReady,
          onComplete: () => setState(() => _introComplete = true),
        ),
      );
    }

    final error = _error;
    if (error != null) {
      return _materialApp(
        themeMode,
        home: InitializationErrorScreen(error: error),
      );
    }

    return MaterialApp.router(
      title: _title,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      scaffoldMessengerKey: _messengerKey,
    );
  }

  /// Warns when the latest edits could not be written to disk and confirms
  /// when a later save succeeds.
  void _showSaveStatus(bool? previous, bool failed) {
    if (failed == (previous ?? false)) return;
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(failed
            ? 'Não foi possível salvar o arquivo. As alterações continuam '
                'abertas nesta sessão; exporte o código para não perdê-lo.'
            : 'Alterações salvas.'),
        duration: Duration(seconds: failed ? 8 : 2),
      ));
  }

  MaterialApp _materialApp(ThemeMode themeMode, {required Widget home}) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: home,
    );
  }
}
