import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'core/compiler/engine_library_path.dart';
import 'src/rust/frb_generated.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? errorInitialization;

  try {
    // Initialize persistence box
    await Hive.initFlutter();
    await Hive.openBox('ide_box');
  } catch (e, stack) {
    debugPrint('Hive initialization failed: $e\n$stack');
    errorInitialization = 'Erro de persistencia (Hive): $e';
  }

  runApp(
    ProviderScope(
      child: MyApp(initialization: _initializeEngine(errorInitialization)),
    ),
  );
}

Future<String?> _initializeEngine(String? persistenceError) async {
  try {
    final libraryPath = bundledEngineLibraryPath();
    await RustLib.init(
      externalLibrary:
          libraryPath == null ? null : ExternalLibrary.open(libraryPath),
    );
    return persistenceError;
  } catch (error, stack) {
    debugPrint('RustLib FFI initialization failed: $error\n$stack');
    return 'Erro de FFI (Rust Core): $error\n\n'
        'Certifique-se de ter compilado o Rust executando "cargo build" '
        'na pasta "rust_core" antes de rodar o Flutter.';
  }
}

class MyApp extends ConsumerStatefulWidget {
  final String? error;
  final Future<String?>? initialization;
  final bool showSplash;

  const MyApp(
      {super.key, this.error, this.initialization, this.showSplash = true});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
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
    final settings = ref.watch(settingsProvider);
    final themeMode = settings.themeMode;
    final lightTheme = AppTheme.lightTheme;

    if (!_introComplete || !_initializationReady) {
      return MaterialApp(
        title: 'Luminthor — Compilador Didático',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: SplashScreen(
          initializationReady: _initializationReady,
          onComplete: () => setState(() => _introComplete = true),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        title: 'Luminthor — Compilador Didático',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: InitializationErrorScreen(error: _error!),
      );
    }

    return MaterialApp.router(
      title: 'Luminthor — Compilador Didático',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

class InitializationErrorScreen extends StatelessWidget {
  final String error;

  const InitializationErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Falha na Inicializacao',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
