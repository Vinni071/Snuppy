import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section Title ──
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Aparência',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Tema Escuro'),
                  subtitle: const Text(
                      'Ativa o tema escuro premium de alta fidelidade visual'),
                  trailing: Switch(
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (_) => notifier.toggleTheme(),
                    activeColor: AppColors.secondary,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Tamanho da Fonte'),
                  subtitle: Text('${settings.fontSize.toInt()} px'),
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(
                      value: settings.fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      activeColor: AppColors.secondary,
                      onChanged: (val) => notifier.setFontSize(val),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Section Title ──
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Sobre o Snuppy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Snuppy — Compilador Educacional Mobile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este aplicativo foi projetado especificamente para auxiliar no ensino e aprendizado de lógica de programação, compiladores e teoria de autômatos.\n\nA engine do compilador é escrita inteiramente em Rust para máxima eficiência e correção, e é integrada via FFI (Flutter Rust Bridge v2) ao app Flutter.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Versão da Engine (Rust):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: const Text('0.1.0 (Lumi)'),
                        backgroundColor: AppColors.surfaceLight,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
