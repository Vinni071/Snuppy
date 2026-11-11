import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminthor/app/router/app_routes.dart';
import 'package:luminthor/features/home/presentation/viewmodels/home_filter.dart';
import 'package:luminthor/features/home/presentation/widgets/home_components.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';

/// Desktop navigation rail with branding, sections and the guide card.
class HomeSidebar extends StatelessWidget {
  final HomePalette palette;
  final HomeSection selected;
  final ValueChanged<HomeSection> onSelect;
  final VoidCallback onShowGuide;

  const HomeSidebar({
    super.key,
    required this.palette,
    required this.selected,
    required this.onSelect,
    required this.onShowGuide,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      width: 218,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
      decoration: BoxDecoration(
          color: p.panel, border: Border(right: BorderSide(color: p.border))),
      child: SidebarContent(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: LuminthorBrand(palette: p)),
        const SizedBox(height: 9),
        Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text('UM ESPAÇO PARA APRENDER',
                style: TextStyle(
                    color: p.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4))),
        const SizedBox(height: 43),
        _navItem('Home', Icons.home_outlined, HomeSection.home),
        const SizedBox(height: 8),
        _navItem('Arquivos recentes', Icons.folder_outlined, HomeSection.files),
        const SizedBox(height: 8),
        _navItem('Templates', Icons.grid_view_rounded, HomeSection.templates),
        const SizedBox(height: 8),
        _navItem('Trilha Lumi', Icons.route_rounded, HomeSection.learning),
        const Spacer(),
        _GuideCard(palette: p, onTap: onShowGuide),
        const SizedBox(height: 24),
        TextButton.icon(
            onPressed: () => context.push(AppRoutes.settings),
            icon: Icon(Icons.tune_rounded, size: 18, color: p.muted),
            label: Text('Configurações',
                style: TextStyle(color: p.muted, fontSize: 12))),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.circle, size: 6, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Linguagem Lumi',
                  style: TextStyle(color: p.muted, fontSize: 10))),
          Text('v1.0', style: TextStyle(color: p.muted, fontSize: 10))
        ]),
      ])),
    );
  }

  Widget _navItem(String label, IconData icon, HomeSection section) =>
      _SidebarNavItem(
        palette: palette,
        label: label,
        icon: icon,
        selected: selected == section,
        onTap: () => onSelect(section),
      );
}

class _SidebarNavItem extends StatelessWidget {
  final HomePalette palette;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.palette,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final color = selected ? p.accent : p.muted;
    return Material(
      color: selected ? p.accentFill : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            child: Row(children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400)))
            ]),
          )),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final HomePalette palette;
  final VoidCallback onTap;

  const _GuideCard({required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return HomeCard(
        palette: p,
        color: p.accentFill,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome_outlined, size: 23, color: p.accent),
          const SizedBox(height: 14),
          Text('Cada linha, uma descoberta.',
              style: TextStyle(
                  color: p.text,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          Text('Explore o que acontece por trás do seu código.',
              style: TextStyle(color: p.muted, fontSize: 11, height: 1.6)),
          const SizedBox(height: 17),
          Row(children: [
            Expanded(
                child: Text('Conheça o Luminthor',
                    style: TextStyle(
                        color: p.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600))),
            Icon(Icons.arrow_forward_rounded, size: 14, color: p.accent)
          ]),
        ]));
  }
}

/// Top bar: section title and search on desktop, brand on mobile.
class HomeHeader extends ConsumerWidget {
  static const _titles = {
    HomeSection.home: 'Seu espaço de criação',
    HomeSection.files: 'Seus arquivos',
    HomeSection.templates: 'Biblioteca de templates',
  };

  final HomePalette palette;
  final bool desktop;
  final HomeSection section;
  final Widget searchField;

  const HomeHeader({
    super.key,
    required this.palette,
    required this.desktop,
    required this.section,
    required this.searchField,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = palette;
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: desktop ? 42 : 22, vertical: 18),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
      child: Row(children: [
        if (desktop) ...[
          Icon(Icons.space_dashboard_outlined, color: p.muted, size: 17),
          const SizedBox(width: 10),
          Text(_titles[section] ?? '',
              style: TextStyle(color: p.muted, fontSize: 12)),
          const Spacer(),
          SizedBox(width: 260, child: searchField),
          const SizedBox(width: 20),
        ] else ...[
          Expanded(child: LuminthorBrand(palette: p)),
        ],
        IconButton(
            tooltip: p.isDark ? 'Ativar tema claro' : 'Ativar tema escuro',
            onPressed: () => ref.read(settingsProvider.notifier).toggleTheme(),
            icon: Icon(
                p.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: p.muted,
                size: 20)),
        if (!desktop)
          IconButton(
              tooltip: 'Configurações',
              onPressed: () => context.push(AppRoutes.settings),
              icon: Icon(Icons.tune_rounded, color: p.muted, size: 20)),
        if (desktop) ...[
          const SizedBox(width: 8),
          HomeTag(label: 'Lumi', color: p.accent, icon: Icons.code_rounded)
        ],
      ]),
    );
  }
}

/// Floating navigation bar used below the desktop breakpoint.
class HomeBottomBar extends StatelessWidget {
  final HomePalette palette;
  final HomeSection selected;
  final ValueChanged<HomeSection> onSelect;

  const HomeBottomBar({
    super.key,
    required this.palette,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      decoration: BoxDecoration(
        color: p.dock,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.dockBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.isDark ? .28 : .10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: NavigationBar(
        key: const ValueKey('home-nav'),
        height: 68,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.accentFill,
        selectedIndex: selected.index,
        onDestinationSelected: (index) => onSelect(HomeSection.values[index]),
        destinations: const [
          NavigationDestination(
              key: ValueKey('home-nav-0'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              key: ValueKey('home-nav-1'),
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder_rounded),
              label: 'Arquivos'),
          NavigationDestination(
              key: ValueKey('home-nav-2'),
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Templates'),
          NavigationDestination(
              key: ValueKey('home-nav-3'),
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route_rounded),
              label: 'Aprender'),
        ],
      ),
    );
  }
}

/// Search field for files and templates.
class HomeSearchField extends StatelessWidget {
  final HomePalette palette;
  final HomeSection section;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const HomeSearchField({
    super.key,
    required this.palette,
    required this.section,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color));
    return TextField(
      key: ValueKey('workspace-search-${section.index}'),
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: p.text, fontSize: 12),
      decoration: InputDecoration(
        hintText: 'Buscar arquivos e templates',
        hintStyle: TextStyle(color: p.muted, fontSize: 12),
        prefixIcon: Icon(Icons.search_rounded, color: p.muted, size: 19),
        filled: true,
        fillColor: p.panel,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
        border: border(p.border),
        enabledBorder: border(p.border),
        focusedBorder: border(p.accent),
      ),
    );
  }
}
