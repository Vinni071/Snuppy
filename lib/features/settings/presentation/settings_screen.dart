import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/presentation/widgets/home_components.dart';
import 'providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final p = HomePalette(Theme.of(context).brightness == Brightness.dark);

    return HomeTheme(
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.text,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          shape: Border(bottom: BorderSide(color: p.border)),
          title: const Text('Configurações',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
              children: [
                _SectionTitle(palette: p, title: 'Aparência'),
                const SizedBox(height: 18),
                HomeCard(
                  palette: p,
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    _SettingRow(
                      palette: p,
                      icon: Icons.palette_outlined,
                      title: 'Tema Escuro',
                      subtitle:
                          'Ativa o tema escuro premium de alta fidelidade visual',
                      trailing: Switch(
                        key: const ValueKey('settings-dark-theme'),
                        value: settings.themeMode == ThemeMode.dark,
                        onChanged: (_) => notifier.toggleTheme(),
                        activeThumbColor: p.onButton,
                        activeTrackColor: p.button,
                        inactiveThumbColor: p.muted,
                        inactiveTrackColor: p.raised,
                        trackOutlineColor: WidgetStatePropertyAll(p.border),
                      ),
                    ),
                    Divider(height: 1, color: p.border),
                    _SettingRow(
                      palette: p,
                      icon: Icons.format_size_rounded,
                      title: 'Tamanho da Fonte',
                      subtitle: '${settings.fontSize.toInt()} px',
                      below: Slider(
                        key: const ValueKey('settings-font-size'),
                        value: settings.fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        activeColor: p.accent,
                        inactiveColor: p.border,
                        label: '${settings.fontSize.toInt()} px',
                        onChanged: notifier.setFontSize,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 34),
                _SectionTitle(palette: p, title: 'Sobre o Luminthor'),
                const SizedBox(height: 18),
                HomeCard(
                  palette: p,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LuminthorBrand(palette: p),
                      const SizedBox(height: 20),
                      Text(
                        'Luminthor — Compilador Educacional Mobile',
                        style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Este aplicativo foi projetado especificamente para auxiliar no ensino e aprendizado de lógica de programação, compiladores e teoria de autômatos.\n\nA engine do compilador é escrita inteiramente em Rust para máxima eficiência e correção, e é integrada via FFI (Flutter Rust Bridge v2) ao app Flutter.',
                        style: TextStyle(
                            color: p.muted, fontSize: 12, height: 1.6),
                      ),
                      const SizedBox(height: 18),
                      Divider(height: 1, color: p.border),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                          child: Text(
                            'Versão da Engine (Rust):',
                            style: TextStyle(
                                color: p.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        HomeTag(label: '0.1.0 (Lumi)', color: p.accent),
                      ]),
                    ],
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

class _SectionTitle extends StatelessWidget {
  final HomePalette palette;
  final String title;
  const _SectionTitle({required this.palette, required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: TextStyle(
          color: palette.text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -.3));
}

class _SettingRow extends StatelessWidget {
  final HomePalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? below;

  const _SettingRow({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.below,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: p.accentFill, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: p.accent, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style: TextStyle(
                            color: p.muted, fontSize: 11, height: 1.5)),
                  ]),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ]),
          if (below != null) ...[const SizedBox(height: 6), below!],
        ]),
      ),
    );
  }
}
