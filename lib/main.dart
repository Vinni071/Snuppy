import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/rust/frb_generated.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

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

  try {
    // Initialize Rust library
    await RustLib.init();
  } catch (e, stack) {
    debugPrint('RustLib FFI initialization failed: $e\n$stack');
    errorInitialization = 'Erro de FFI (Rust Core): $e\n\n'
        'Certifique-se de ter compilado o Rust executando "cargo build" '
        'na pasta "rust_core" antes de rodar o Flutter.';
  }

  runApp(
    ProviderScope(
      child: MyApp(error: errorInitialization),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final String? error;
  const MyApp({super.key, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If there is an initialization error, we bypass settings reading
    // to avoid throwing further provider lookup issues.
    final settings = error == null ? ref.watch(settingsProvider) : null;
    final themeMode = settings?.themeMode ?? ThemeMode.dark;
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: AppTheme.darkTheme.primaryColor,
    );

    if (error != null) {
      return MaterialApp(
        title: 'Snuppy - Compilador Didatico',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: InitializationErrorScreen(error: error!),
      );
    }

    return MaterialApp.router(
      title: 'Snuppy - Compilador Didatico',
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
