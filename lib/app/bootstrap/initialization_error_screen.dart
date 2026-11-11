import 'package:flutter/material.dart';

/// Shown instead of the router when storage or the Rust engine failed to load.
class InitializationErrorScreen extends StatelessWidget {
  final String error;

  const InitializationErrorScreen({super.key, required this.error});

  static const _background = Color(0xFF0B0F19);
  static const _surface = Color(0xFF1E293B);
  static const _danger = Color(0xFFEF4444);
  static const _body = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _danger, width: 1.5),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: _danger, size: 48),
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
                  style: const TextStyle(color: _body, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
