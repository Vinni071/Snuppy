import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminthor/app/router/app_routes.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/home/presentation/viewmodels/home_filter.dart';
import 'package:luminthor/features/home/presentation/widgets/home_components.dart';
import 'package:luminthor/features/home/presentation/widgets/home_guide_dialog.dart';
import 'package:luminthor/features/home/presentation/widgets/home_navigation.dart';
import 'package:luminthor/features/home/presentation/widgets/home_sections.dart';
import 'package:luminthor/features/home/presentation/widgets/new_file_dialog.dart';
import 'package:luminthor/features/learning/presentation/screens/learning_screen.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';
import 'package:luminthor/features/workspace/data/datasources/workspace_file_service.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

export 'package:luminthor/features/home/presentation/viewmodels/home_filter.dart'
    show HomeSection;

class HomeScreen extends ConsumerStatefulWidget {
  final HomeSection initialSection;

  const HomeScreen({super.key, this.initialSection = HomeSection.home});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeFilter _filter = HomeFilter(section: widget.initialSection);
  bool _opening = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDocument(WorkspaceDocument document) {
    ref.read(editorProvider.notifier).openDocument(document);
    context.go(AppRoutes.editor);
  }

  void _createAndOpen({
    required String name,
    String source = '',
    String origin = DocumentOrigin.created,
  }) {
    ref
        .read(editorProvider.notifier)
        .createDocument(name: name, source: source, origin: origin);
    context.go(AppRoutes.editor);
  }

  Future<void> _newFile() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const HomeTheme(child: NewFileDialog()),
    );
    if (name == null || !mounted) return;
    _createAndOpen(name: ensureLumiExtension(name));
  }

  Future<void> _importFile() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final imported = await ref.read(workspaceFileServiceProvider).open();
      if (!mounted || imported == null) return;
      _createAndOpen(
          name: imported.name,
          source: imported.source,
          origin: DocumentOrigin.imported);
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

  void _useTemplate(CodeTemplate template) => _createAndOpen(
      name: template.fileName,
      source: template.code,
      origin: DocumentOrigin.template(template.title));

  void _showGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => const HomeTheme(child: HomeGuideDialog()),
    );
  }

  void _selectSection(HomeSection section) {
    setState(() {
      _filter = _filter.selectSection(section);
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        HomePalette(Theme.of(context).brightness == Brightness.dark);
    final appTheme = Theme.of(context);
    final learning = _filter.showsLearning;
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
                    if (desktop)
                      HomeSidebar(
                          palette: palette,
                          selected: _filter.section,
                          onSelect: _selectSection,
                          onShowGuide: _showGuide),
                    Expanded(
                        child: Column(children: [
                      if (!learning)
                        HomeHeader(
                            palette: palette,
                            desktop: desktop,
                            section: _filter.section,
                            searchField: _searchField(palette)),
                      Expanded(
                          child: Stack(fit: StackFit.expand, children: [
                        if (learning)
                          Theme(
                            data: appTheme,
                            child: LearningScreen(
                                bottomSpace: desktop ? 0 : 88 + bottomInset),
                          )
                        else
                          _content(palette, desktop),
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
                                child: HomeBottomBar(
                                    palette: palette,
                                    selected: _filter.section,
                                    onSelect: _selectSection),
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

  Widget _searchField(HomePalette palette) => HomeSearchField(
        palette: palette,
        section: _filter.section,
        controller: _searchController,
        onChanged: (value) => setState(() => _filter = _filter.search(value)),
      );

  Widget _content(HomePalette palette, bool desktop) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)), child: child)),
      child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              key: ValueKey('home-section-${_filter.section.index}'),
              padding: EdgeInsets.fromLTRB(
                  desktop ? 42 : 22, 28, desktop ? 42 : 22, desktop ? 28 : 112),
              children: [
                if (!desktop) ...[
                  _searchField(palette),
                  const SizedBox(height: 26)
                ],
                if (_filter.showsHero) ...[
                  HomeHero(
                      palette: palette,
                      onNewFile: _newFile,
                      onOpenLearning: () =>
                          _selectSection(HomeSection.learning)),
                  const SizedBox(height: 24),
                  HomeQuickActions(
                      palette: palette,
                      opening: _opening,
                      onNewFile: _newFile,
                      onImportFile: _importFile,
                      onExploreTemplates: () =>
                          _selectSection(HomeSection.templates)),
                  const SizedBox(height: 35),
                ],
                if (_filter.showsRecentFiles) ...[
                  // Only this section depends on the documents, so only it
                  // rebuilds when a file is saved.
                  Consumer(
                    builder: (context, ref, _) => RecentFilesSection(
                        palette: palette,
                        filter: _filter,
                        documents: ref.watch(
                            workspaceProvider.select((w) => w.documents)),
                        opening: _opening,
                        onOpen: _openDocument,
                        onImportFile: _importFile,
                        onNewFile: _newFile,
                        onSeeAll: () => _selectSection(HomeSection.files)),
                  ),
                  const SizedBox(height: 34)
                ],
                if (_filter.showsTemplates)
                  TemplatesSection(
                      palette: palette,
                      filter: _filter,
                      onUse: _useTemplate,
                      onSelectCategory: (category) => setState(
                          () => _filter = _filter.selectCategory(category)),
                      onExplore: () => _selectSection(HomeSection.templates)),
                const SizedBox(height: 30),
                HomeFooter(palette: palette, onShowGuide: _showGuide),
              ],
            ),
          )),
    );
  }
}
