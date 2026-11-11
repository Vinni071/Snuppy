import 'package:flutter/material.dart';
import 'package:luminthor/core/utils/relative_date.dart';
import 'package:luminthor/features/home/presentation/viewmodels/home_filter.dart';
import 'package:luminthor/features/home/presentation/widgets/home_components.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

/// Welcome banner with the primary "new file" call to action.
class HomeHero extends StatelessWidget {
  final HomePalette palette;
  final VoidCallback onNewFile;
  final VoidCallback onOpenLearning;

  const HomeHero({
    super.key,
    required this.palette,
    required this.onNewFile,
    required this.onOpenLearning,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 780;
      return Container(
        padding: EdgeInsets.all(wide ? 32 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [p.raised, p.panel],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.border),
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Seu próximo código\ncomeça aqui.',
                    style: TextStyle(
                        color: p.text,
                        fontSize: wide ? 35 : 30,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.1)),
                const SizedBox(height: 15),
                Text(
                    'Um espaço para criar, experimentar e entender\ncomo a programação funciona.',
                    style:
                        TextStyle(color: p.muted, height: 1.65, fontSize: 13)),
                const SizedBox(height: 25),
                FilledButton.icon(
                  key: const ValueKey('hero-new-file'),
                  onPressed: onNewFile,
                  style: FilledButton.styleFrom(
                      backgroundColor: p.button,
                      foregroundColor: p.onButton,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.add_rounded, size: 19),
                  label: const Text('Criar meu primeiro código',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  key: const ValueKey('home-learning'),
                  onPressed: onOpenLearning,
                  icon: const Icon(Icons.route_rounded, size: 18),
                  label: const Text('Aprender com a Trilha Lumi',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ])),
          if (wide) ...[const SizedBox(width: 30), LumiPreview(palette: p)],
        ]),
      );
    });
  }
}

/// New file / open file / explore templates shortcuts.
class HomeQuickActions extends StatelessWidget {
  final HomePalette palette;
  final bool opening;
  final VoidCallback onNewFile;
  final VoidCallback onImportFile;
  final VoidCallback onExploreTemplates;

  const HomeQuickActions({
    super.key,
    required this.palette,
    required this.opening,
    required this.onNewFile,
    required this.onImportFile,
    required this.onExploreTemplates,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      final actions = [
        HomeActionCard(
            palette: p,
            icon: Icons.note_add_outlined,
            title: 'Novo arquivo',
            description: 'Uma página em branco para sua ideia.',
            accent: p.accent,
            compact: compact,
            onTap: onNewFile),
        HomeActionCard(
            palette: p,
            icon: opening
                ? Icons.hourglass_top_rounded
                : Icons.folder_open_rounded,
            title: opening ? 'Abrindo arquivo...' : 'Abrir arquivo',
            description: 'Traga um arquivo .lumi ou .txt.',
            accent: p.accent,
            compact: compact,
            onTap: opening ? null : onImportFile),
        HomeActionCard(
            palette: p,
            icon: Icons.dashboard_customize_outlined,
            title: 'Explorar templates',
            description: 'Aprenda com exemplos prontos.',
            accent: p.accent,
            compact: compact,
            onTap: onExploreTemplates),
      ];
      if (compact) {
        return Column(children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            actions[i]
          ]
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: actions[i])
        ]
      ]);
    });
  }
}

class HomeSectionTitle extends StatelessWidget {
  final HomePalette palette;
  final String title;
  final String subtitle;
  final Widget? action;

  const HomeSectionTitle({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final action = this.action;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: p.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -.3)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: TextStyle(color: p.muted, fontSize: 12, height: 1.5))
      ])),
      if (action != null) ...[const SizedBox(width: 12), action],
    ]);
  }
}

/// Recent workspace files, filtered by the current search.
class RecentFilesSection extends StatelessWidget {
  final HomePalette palette;
  final HomeFilter filter;
  final List<WorkspaceDocument> documents;
  final bool opening;
  final ValueChanged<WorkspaceDocument> onOpen;
  final VoidCallback onImportFile;
  final VoidCallback onNewFile;
  final VoidCallback onSeeAll;

  const RecentFilesSection({
    super.key,
    required this.palette,
    required this.filter,
    required this.documents,
    required this.opening,
    required this.onOpen,
    required this.onImportFile,
    required this.onNewFile,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final matches = filter.matchingDocuments(documents);
    final visible = filter.visibleDocuments(matches);
    final section = filter.section;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      HomeSectionTitle(
          palette: p,
          title: 'Arquivos recentes',
          subtitle: 'Continue de onde a sua ideia parou.',
          action: section == HomeSection.home && matches.isNotEmpty
              ? TextButton(
                  onPressed: onSeeAll,
                  child: Text('Ver todos',
                      style: TextStyle(color: p.accent, fontSize: 12)))
              : section == HomeSection.files
                  ? IconButton(
                      tooltip: 'Abrir arquivo',
                      onPressed: opening ? null : onImportFile,
                      icon: Icon(Icons.folder_open_outlined, color: p.accent))
                  : null),
      const SizedBox(height: 18),
      if (visible.isEmpty)
        _EmptyRecentFiles(palette: p, searching: filter.query.isNotEmpty),
      for (var i = 0; i < visible.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        _RecentFileCard(
            palette: p, document: visible[i], onTap: () => onOpen(visible[i])),
      ],
      if (section == HomeSection.files) ...[
        const SizedBox(height: 16),
        OutlinedButton.icon(
            onPressed: onNewFile,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Novo arquivo'))
      ],
    ]);
  }
}

class _EmptyRecentFiles extends StatelessWidget {
  final HomePalette palette;
  final bool searching;

  const _EmptyRecentFiles({required this.palette, required this.searching});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return HomeCard(
        palette: p,
        padding: const EdgeInsets.all(24),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: p.raised, borderRadius: BorderRadius.circular(14)),
              child:
                  Icon(Icons.description_outlined, color: p.muted, size: 26)),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    searching
                        ? 'Nenhum arquivo encontrado'
                        : 'Sua próxima criação aparece aqui',
                    style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                    searching
                        ? 'Experimente buscar por outro nome.'
                        : 'Crie ou abra um arquivo. Seus códigos ficam salvos neste dispositivo.',
                    style: TextStyle(color: p.muted, fontSize: 12, height: 1.6))
              ])),
        ]));
  }
}

class _RecentFileCard extends StatelessWidget {
  final HomePalette palette;
  final WorkspaceDocument document;
  final VoidCallback onTap;

  const _RecentFileCard({
    required this.palette,
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return HomeCard(
        palette: p,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        onTap: onTap,
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: p.accentFill, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.code_rounded, color: p.accent, size: 21)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(document.origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.muted, fontSize: 11))
              ])),
          const SizedBox(width: 12),
          Text(formatRelativeDate(document.updatedAt),
              style: TextStyle(color: p.muted, fontSize: 10)),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right_rounded, color: p.muted, size: 19),
        ]));
  }
}

/// Template gallery with category chips on the templates section.
class TemplatesSection extends StatelessWidget {
  final HomePalette palette;
  final HomeFilter filter;
  final ValueChanged<CodeTemplate> onUse;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onExplore;

  const TemplatesSection({
    super.key,
    required this.palette,
    required this.filter,
    required this.onUse,
    required this.onSelectCategory,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final visible = filter.visibleTemplates(EditorTemplates.templates);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      HomeSectionTitle(
          palette: p,
          title: 'Comece com um template',
          subtitle: 'Pequenos exemplos. Grandes descobertas.',
          action: filter.section == HomeSection.home
              ? TextButton(
                  onPressed: onExplore,
                  child: Text('Explorar',
                      style: TextStyle(color: p.accent, fontSize: 12)))
              : null),
      const SizedBox(height: 19),
      if (filter.showsCategoryFilter) ...[
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final category in EditorTemplates.categories)
            ChoiceChip(
              label: Text(category,
                  style: TextStyle(
                      fontSize: 11,
                      color: filter.category == category ? p.accent : p.muted)),
              selected: filter.category == category,
              showCheckmark: false,
              selectedColor: p.accentFill,
              backgroundColor: p.panel,
              side: BorderSide(
                  color: filter.category == category
                      ? p.accent.withValues(alpha: .4)
                      : p.border),
              onSelected: (_) => onSelectCategory(category),
            )
        ]),
        const SizedBox(height: 20),
      ],
      if (visible.isEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
                'Nenhum template encontrado. Experimente outro termo ou categoria.',
                style: TextStyle(color: p.muted, fontSize: 13))),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 740
            ? 3
            : constraints.maxWidth >= 490
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(spacing: 16, runSpacing: 16, children: [
          for (final template in visible)
            SizedBox(
                width: width,
                child: TemplateCard(
                    palette: p,
                    template: template,
                    onTap: () => onUse(template)))
        ]);
      }),
    ]);
  }
}

class TemplateCard extends StatelessWidget {
  static const _icons = [
    Icons.data_object_rounded,
    Icons.alt_route_rounded,
    Icons.repeat_rounded,
    Icons.functions_rounded,
    Icons.bug_report_outlined,
    Icons.layers_outlined,
  ];

  final HomePalette palette;
  final CodeTemplate template;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.palette,
    required this.template,
    required this.onTap,
  });

  IconData get _icon {
    final index = EditorTemplates.templates.indexOf(template);
    return index >= 0 && index < _icons.length
        ? _icons[index]
        : Icons.code_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final color = p.accent;
    return HomeCard(
        palette: p,
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 106,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: color.withValues(alpha: .055),
                border: Border(bottom: BorderSide(color: p.border))),
            child: Row(children: [
              Icon(_icon, color: color.withValues(alpha: .7), size: 31),
              const SizedBox(width: 18),
              Expanded(
                  child: Text(template.preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: color.withValues(alpha: .85),
                          fontFamily: 'monospace',
                          fontSize: 10,
                          height: 1.8))),
            ]),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeTag(label: template.category, color: color),
                    const SizedBox(height: 15),
                    Text(template.title,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(template.description,
                        style: TextStyle(
                            color: p.muted, fontSize: 12, height: 1.65)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Text('Usar template',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded, color: color, size: 16)
                    ]),
                  ])),
        ]));
  }
}

class HomeFooter extends StatelessWidget {
  final HomePalette palette;
  final VoidCallback onShowGuide;

  const HomeFooter({
    super.key,
    required this.palette,
    required this.onShowGuide,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(children: [
      Divider(color: p.border),
      const SizedBox(height: 16),
      Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            Icon(Icons.code_rounded, size: 14, color: p.muted),
            Text('Feito para aprender, criado para explorar.',
                style: TextStyle(color: p.muted, fontSize: 10)),
            TextButton(
                onPressed: onShowGuide,
                child: Text('Como funciona',
                    style: TextStyle(color: p.accent, fontSize: 10)))
          ]),
    ]);
  }
}
