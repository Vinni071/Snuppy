import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/editor_templates.dart';
import '../../editor/presentation/providers/editor_provider.dart';
import '../../learning/presentation/learning_screen.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import '../data/workspace_file_service.dart';
import '../domain/workspace_document.dart';
import 'providers/workspace_provider.dart';
import 'widgets/home_components.dart';
import 'widgets/new_file_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const learningSection = 3;

  final int initialSection;
  const HomeScreen({super.key, this.initialSection = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _section = widget.initialSection;
  String _query = '';
  String _category = 'Todos';
  bool _opening = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDocument(WorkspaceDocument document) {
    ref.read(editorProvider.notifier).openDocument(document);
    context.go('/editor');
  }

  Future<void> _newFile() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const HomeTheme(child: NewFileDialog()),
    );
    if (name == null || !mounted) return;
    final document = ref.read(workspaceProvider.notifier).create(
        name: name.toLowerCase().endsWith('.lumi') ? name : '$name.lumi');
    _openDocument(document);
  }

  Future<void> _importFile() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final imported = await ref.read(workspaceFileServiceProvider).open();
      if (!mounted || imported == null) return;
      final document = ref.read(workspaceProvider.notifier).create(
          name: imported.name,
          source: imported.source,
          origin: 'Importado do dispositivo');
      _openDocument(document);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error is FormatException
                ? 'Não foi possível ler este arquivo. Escolha um arquivo de texto UTF-8 (.lumi ou .txt).'
                : 'Não foi possível abrir o arquivo. Tente novamente.')));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _useTemplate(CodeTemplate template) {
    final document = ref.read(workspaceProvider.notifier).create(
        name: template.fileName,
        source: template.code,
        origin: 'Template · ${template.title}');
    _openDocument(document);
  }

  void _showGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => HomeTheme(
          child: AlertDialog(
        title: const Text('Da ideia à execução'),
        content: const SizedBox(
            width: 380,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideStep(
                      number: '01',
                      title: 'Escreva em Lumi',
                      description:
                          'Crie um arquivo ou escolha um template para começar.'),
                  SizedBox(height: 20),
                  _GuideStep(
                      number: '02',
                      title: 'Execute e explore',
                      description:
                          'Toque em Execute. Veja a saída, os tokens e a árvore de sintaxe nas abas do editor.'),
                  SizedBox(height: 20),
                  _GuideStep(
                      number: '03',
                      title: 'Entenda cada passo',
                      description:
                          'Na aba de depuração, acompanhe as variáveis e avance pela execução do programa.'),
                ])),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vamos começar'))
        ],
      )),
    );
  }

  void _selectSection(int index) {
    setState(() {
      _section = index;
      _query = '';
      _category = 'Todos';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        HomePalette(Theme.of(context).brightness == Brightness.dark);
    final workspace = ref.watch(workspaceProvider);
    final appTheme = Theme.of(context);
    final learning = _section == HomeScreen.learningSection;
    return HomeTheme(
        child: Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1040;
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          // The learning action bar runs to the screen edge, under the dock.
          final edgeToEdge = learning && !desktop;
          return SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: !edgeToEdge,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (desktop) _sidebar(palette),
                    Expanded(
                        child: Column(children: [
                      if (!learning) _header(palette, desktop),
                      Expanded(
                          child: Stack(fit: StackFit.expand, children: [
                        if (learning)
                          Theme(
                            data: appTheme,
                            child: LearningScreen(
                                bottomSpace: desktop ? 0 : 88 + bottomInset),
                          )
                        else
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                    offset: Offset(0, 12 * (1 - value)),
                                    child: child)),
                            child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1200),
                                  child: ListView(
                                    key: ValueKey('home-section-$_section'),
                                    padding: EdgeInsets.fromLTRB(
                                        desktop ? 42 : 22,
                                        28,
                                        desktop ? 42 : 22,
                                        desktop ? 28 : 112),
                                    children: [
                                      if (!desktop) ...[
                                        _search(palette),
                                        const SizedBox(height: 26)
                                      ],
                                      if (_section == 0 && _query.isEmpty) ...[
                                        _hero(palette),
                                        const SizedBox(height: 24),
                                        _actions(palette),
                                        const SizedBox(height: 35),
                                      ],
                                      if (_section != 2) ...[
                                        _recents(palette, workspace),
                                        const SizedBox(height: 34)
                                      ],
                                      if (_section != 1) _templates(palette),
                                      const SizedBox(height: 30),
                                      _footer(palette),
                                    ],
                                  ),
                                )),
                          ),
                        if (!desktop)
                          Positioned(
                            left: 22,
                            right: 22,
                            bottom: 16 + (edgeToEdge ? bottomInset : 0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 460),
                                child: _bottomBar(palette),
                              ),
                            ),
                          ),
                      ])),
                    ])),
                  ]));
        }),
      ),
    ));
  }

  Widget _bottomBar(HomePalette p) {
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
        selectedIndex: _section,
        onDestinationSelected: _selectSection,
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

  Widget _sidebar(HomePalette p) {
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
        _navItem(p, 'Home', Icons.home_outlined, 0),
        const SizedBox(height: 8),
        _navItem(p, 'Arquivos recentes', Icons.folder_outlined, 1),
        const SizedBox(height: 8),
        _navItem(p, 'Templates', Icons.grid_view_rounded, 2),
        const SizedBox(height: 8),
        _navItem(p, 'Trilha Lumi', Icons.route_rounded, 3),
        const Spacer(),
        HomeCard(
            palette: p,
            color: p.accentFill,
            padding: const EdgeInsets.all(16),
            onTap: _showGuide,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            ])),
        const SizedBox(height: 24),
        TextButton.icon(
            onPressed: () => context.push('/settings'),
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

  Widget _navItem(HomePalette p, String label, IconData icon, int index) {
    final selected = _section == index;
    return Material(
      color: selected ? p.accentFill : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
          onTap: () => _selectSection(index),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            child: Row(children: [
              Icon(icon, size: 19, color: selected ? p.accent : p.muted),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: selected ? p.accent : p.muted,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400)))
            ]),
          )),
    );
  }

  Widget _header(HomePalette p, bool desktop) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: desktop ? 42 : 22, vertical: 18),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
      child: Row(children: [
        if (desktop) ...[
          Icon(Icons.space_dashboard_outlined, color: p.muted, size: 17),
          const SizedBox(width: 10),
          Text(
              [
                'Seu espaço de criação',
                'Seus arquivos',
                'Biblioteca de templates'
              ][_section],
              style: TextStyle(color: p.muted, fontSize: 12)),
          const Spacer(),
          SizedBox(width: 260, child: _search(p)),
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
              onPressed: () => context.push('/settings'),
              icon: Icon(Icons.tune_rounded, color: p.muted, size: 20)),
        if (desktop) ...[
          const SizedBox(width: 8),
          HomeTag(label: 'Lumi', color: p.accent, icon: Icons.code_rounded)
        ],
      ]),
    );
  }

  Widget _search(HomePalette p) {
    return TextField(
      key: ValueKey('workspace-search-$_section'),
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value.toLowerCase().trim()),
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
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: p.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: p.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: p.accent)),
      ),
    );
  }

  Widget _hero(HomePalette p) {
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
                  onPressed: _newFile,
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
                  onPressed: () => _selectSection(HomeScreen.learningSection),
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

  Widget _actions(HomePalette p) {
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
            onTap: _newFile),
        HomeActionCard(
            palette: p,
            icon: _opening
                ? Icons.hourglass_top_rounded
                : Icons.folder_open_rounded,
            title: _opening ? 'Abrindo arquivo...' : 'Abrir arquivo',
            description: 'Traga um arquivo .lumi ou .txt.',
            accent: p.accent,
            compact: compact,
            onTap: _opening ? null : _importFile),
        HomeActionCard(
            palette: p,
            icon: Icons.dashboard_customize_outlined,
            title: 'Explorar templates',
            description: 'Aprenda com exemplos prontos.',
            accent: p.accent,
            compact: compact,
            onTap: () => _selectSection(2)),
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

  Widget _sectionTitle(HomePalette p, String title, String subtitle,
      {Widget? action}) {
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

  Widget _recents(HomePalette p, WorkspaceState workspace) {
    final matches = workspace.documents
        .where((document) => document.name.toLowerCase().contains(_query))
        .toList();
    final visible = _section == 0 ? matches.take(3).toList() : matches;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(
          p, 'Arquivos recentes', 'Continue de onde a sua ideia parou.',
          action: _section == 0 && matches.isNotEmpty
              ? TextButton(
                  onPressed: () => _selectSection(1),
                  child: Text('Ver todos',
                      style: TextStyle(color: p.accent, fontSize: 12)))
              : _section == 1
                  ? IconButton(
                      tooltip: 'Abrir arquivo',
                      onPressed: _opening ? null : _importFile,
                      icon: Icon(Icons.folder_open_outlined, color: p.accent))
                  : null),
      const SizedBox(height: 18),
      if (visible.isEmpty)
        HomeCard(
            palette: p,
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: p.raised, borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.description_outlined,
                      color: p.muted, size: 26)),
              const SizedBox(width: 18),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        _query.isEmpty
                            ? 'Sua próxima criação aparece aqui'
                            : 'Nenhum arquivo encontrado',
                        style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                        _query.isEmpty
                            ? 'Crie ou abra um arquivo. Seus códigos ficam salvos neste dispositivo.'
                            : 'Experimente buscar por outro nome.',
                        style: TextStyle(
                            color: p.muted, fontSize: 12, height: 1.6))
                  ])),
            ])),
      for (var i = 0; i < visible.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        HomeCard(
            palette: p,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            onTap: () => _openDocument(visible[i]),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: p.accentFill,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.code_rounded, color: p.accent, size: 21)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(visible[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text(visible[i].origin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.muted, fontSize: 11))
                  ])),
              const SizedBox(width: 12),
              Text(_relativeDate(visible[i].updatedAt),
                  style: TextStyle(color: p.muted, fontSize: 10)),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right_rounded, color: p.muted, size: 19),
            ])),
      ],
      if (_section == 1) ...[
        const SizedBox(height: 16),
        OutlinedButton.icon(
            onPressed: _newFile,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Novo arquivo'))
      ],
    ]);
  }

  Widget _templates(HomePalette p) {
    final matches = EditorTemplates.templates
        .where((template) =>
            (_category == 'Todos' || template.category == _category) &&
            '${template.title} ${template.description} ${template.category}'
                .toLowerCase()
                .contains(_query))
        .toList();
    final visible =
        _section == 0 && _query.isEmpty ? matches.take(3).toList() : matches;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(p, 'Comece com um template',
          'Pequenos exemplos. Grandes descobertas.',
          action: _section == 0
              ? TextButton(
                  onPressed: () => _selectSection(2),
                  child: Text('Explorar',
                      style: TextStyle(color: p.accent, fontSize: 12)))
              : null),
      const SizedBox(height: 19),
      if (_section == 2) ...[
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final category in [
            'Todos',
            'Fundamentos',
            'Controle de fluxo',
            'Funções',
            'Depuração'
          ])
            ChoiceChip(
              label: Text(category,
                  style: TextStyle(
                      fontSize: 11,
                      color: _category == category ? p.accent : p.muted)),
              selected: _category == category,
              showCheckmark: false,
              selectedColor: p.accentFill,
              backgroundColor: p.panel,
              side: BorderSide(
                  color: _category == category
                      ? p.accent.withValues(alpha: .4)
                      : p.border),
              onSelected: (_) => setState(() => _category = category),
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
            SizedBox(width: width, child: _templateCard(p, template))
        ]);
      }),
    ]);
  }

  Widget _templateCard(HomePalette p, CodeTemplate template) {
    final index = EditorTemplates.templates.indexOf(template);
    final color = p.accent;
    final icon = [
      Icons.data_object_rounded,
      Icons.alt_route_rounded,
      Icons.repeat_rounded,
      Icons.functions_rounded,
      Icons.bug_report_outlined,
      Icons.layers_outlined
    ][index];
    return HomeCard(
        palette: p,
        onTap: () => _useTemplate(template),
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
              Icon(icon, color: color.withValues(alpha: .7), size: 31),
              const SizedBox(width: 18),
              Expanded(
                  child: Text(_templatePreview(index),
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

  Widget _footer(HomePalette p) => Column(children: [
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
                  onPressed: _showGuide,
                  child: Text('Como funciona',
                      style: TextStyle(color: p.accent, fontSize: 10)))
            ]),
      ]);

  String _relativeDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return 'Há ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Há ${difference.inHours} h';
    if (difference.inDays == 1) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _templatePreview(int index) => [
        'var ideia = 15;\nconst passo = 27;\nprint(ideia + passo);',
        'if nota >= 70 {\n  print("Muito bem!");\n}',
        'while n > 1 {\n  resultado = resultado * n;\n}',
        'fn escalar(numero) {\n  return numero * fator;\n}',
        'var minhaVariavel = 100;\nprint(minhaVarivel);\n// Encontre o erro ↑',
        'if true {\n  var mensagem = "Olá!";\n}',
      ][index];
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  const _GuideStep(
      {required this.number, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(number,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700)),
      const SizedBox(width: 14),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(fontSize: 13, height: 1.5))
      ])),
    ]);
  }
}
