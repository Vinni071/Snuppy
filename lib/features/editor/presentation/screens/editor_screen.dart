import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminthor/app/router/app_routes.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/features/editor/domain/lumi_keyboard_shortcuts.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/editor/presentation/widgets/ast_tab.dart';
import 'package:luminthor/features/editor/presentation/widgets/debugger_tab.dart';
import 'package:luminthor/features/editor/presentation/widgets/editor_chrome.dart';
import 'package:luminthor/features/editor/presentation/widgets/editor_dock.dart';
import 'package:luminthor/features/editor/presentation/widgets/editor_sheets.dart';
import 'package:luminthor/features/editor/presentation/widgets/editor_tab.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_controller.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_keyboard_toolbar.dart';
import 'package:luminthor/features/editor/presentation/widgets/tokens_tab.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';
import 'package:luminthor/features/workspace/data/datasources/workspace_file_service.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final bool fromLearning;
  const EditorScreen({super.key, this.fromLearning = false});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entranceController;
  late Animation<double> _dockSlideAnimation;
  late Animation<double> _topBarFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late LumiCodeController _codeController;
  late FocusNode _codeFocusNode;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _codeController = LumiCodeController(text: ref.read(editorProvider).source);
    _codeFocusNode = FocusNode()..addListener(_refreshEditorFocus);
    _tabController =
        TabController(length: EditorPanel.values.length, vsync: this);
    _tabController.addListener(_refreshSelectedTab);

    // Entrance animation controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _dockSlideAnimation = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _topBarFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _contentFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );

    _entranceController.forward();

    // Keep the editor text in sync when the source is replaced from outside
    // the editor (opening a document or a template). Typing is a no-op here
    // because the controller already holds the new text.
    ref.listenManual(editorProvider.select((s) => s.source), (_, source) {
      if (_codeController.text != source) _codeController.text = source;
    });

    // Automatically navigate to debugger tab when debugger starts
    ref.listenManual(editorProvider, (previous, next) {
      if (next.isDebugging && previous?.isDebugging != true) {
        _tabController.animateTo(EditorPanel.trace.index);
      }
    });
  }

  void _refreshSelectedTab() {
    if (_tabController.index != EditorPanel.code.index) {
      _codeFocusNode.unfocus();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshEditorFocus() {
    if (mounted) setState(() {});
  }

  void _insertShortcut(LumiKeyboardShortcut shortcut) {
    if (ref.read(editorProvider).isDebugging) return;
    _codeController.insertText(shortcut.text, suffix: shortcut.suffix);
    ref.read(editorProvider.notifier).updateSource(_codeController.text);
    _codeFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.removeListener(_refreshSelectedTab);
    _tabController.dispose();
    _entranceController.dispose();
    _codeFocusNode.removeListener(_refreshEditorFocus);
    _codeFocusNode.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _runCompilation() async {
    final notifier = ref.read(editorProvider.notifier);
    await notifier.runCompilation();

    if (!mounted) return;

    final result = ref.read(editorProvider).compileResult;
    final isSuccessful = result != null && result.success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccessful
              ? 'Compilacao concluida com sucesso!'
              : 'Compilacao falhou. Verifique o terminal de diagnosticos.',
          style: TextStyle(color: context.editorColors.onStatus),
        ),
        backgroundColor: isSuccessful
            ? context.editorColors.success
            : context.editorColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportFile() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final name =
          ref.read(workspaceProvider).activeDocument?.name ?? 'Editor.lumi';
      final exported = await ref.read(workspaceFileServiceProvider).export(
            name: name,
            source: ref.read(editorProvider).source,
          );
      if (mounted && exported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arquivo exportado com sucesso.')),
        );
      }
    } catch (error, stack) {
      reportError('Falha ao exportar arquivo', error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Não foi possível exportar o arquivo. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showTemplateSheet() {
    _codeFocusNode.unfocus();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.editorColors.panel,
      barrierColor: Colors.black54,
      showDragHandle: true,
      builder: (sheetContext) => TemplatePickerSheet(
        onSelected: (template) {
          _openTemplate(template);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  void _openTemplate(CodeTemplate template) {
    ref.read(editorProvider.notifier).createDocument(
          name: template.fileName,
          source: template.code,
          origin: DocumentOrigin.template(template.title),
        );
    _tabController.animateTo(EditorPanel.code.index);
  }

  void _showSearchSheet() {
    _codeFocusNode.unfocus();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.editorColors.panel,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          SourceSearchSheet(source: ref.read(editorProvider).source),
    );
  }

  void _goBack() {
    if (widget.fromLearning && context.canPop()) {
      context.pop();
    } else {
      context.go(widget.fromLearning ? AppRoutes.learning : AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The screen only reacts to these two fields; the tabs watch the rest.
    final isLoading = ref.watch(editorProvider.select((s) => s.isLoading));
    final isDebugging = ref.watch(editorProvider.select((s) => s.isDebugging));
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final fontSize = ref.watch(settingsProvider.select((s) => s.fontSize));
    final wantsKeyboardShortcuts = keyboardVisible &&
        _codeFocusNode.hasFocus &&
        _tabController.index == EditorPanel.code.index &&
        !isDebugging;

    return Scaffold(
      backgroundColor: context.editorColors.background,
      body: LayoutBuilder(builder: (context, bodyConstraints) {
        // Scaffold has already removed the keyboard from these constraints.
        final compact = bodyConstraints.maxHeight < 360;
        final verticalInset = compact ? 4.0 : 10.0;
        return SafeArea(
          minimum: EdgeInsets.fromLTRB(11, verticalInset, 11, verticalInset),
          child: LayoutBuilder(builder: (context, constraints) {
            final toolbarHeight = compact ? 48.0 : 56.0;
            final lineHeight =
                MediaQuery.textScalerOf(context).scale(fontSize) * 1.48;
            // Keep two code lines visible; shortcuts yield to the editor when
            // the keyboard or a larger font leaves too little room.
            final showKeyboardShortcuts = wantsKeyboardShortcuts &&
                constraints.maxHeight >=
                    toolbarHeight + 8 + lineHeight * 2 + 12;
            final contentBottom = showKeyboardShortcuts
                ? toolbarHeight + 8
                : keyboardVisible
                    ? 0.0
                    : compact
                        ? 70.0
                        : 78.0;
            return AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Top bar with fade-in
                    if (!(compact && keyboardVisible))
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: FadeTransition(
                          opacity: _topBarFadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              EditorRoundIconButton(
                                icon: widget.fromLearning
                                    ? Icons.arrow_back_rounded
                                    : Icons.home_outlined,
                                tooltip: widget.fromLearning
                                    ? 'Voltar à aula'
                                    : 'Voltar à Home',
                                onPressed: _goBack,
                              ),
                              const SizedBox(width: 10),
                              EditorRoundIconButton(
                                icon: Icons.menu,
                                tooltip: 'Modelos',
                                onPressed: _showTemplateSheet,
                              ),
                              const Spacer(),
                              EditorRoundIconButton(
                                icon: _exporting
                                    ? Icons.hourglass_top_rounded
                                    : Icons.file_download_outlined,
                                tooltip: 'Exportar arquivo',
                                onPressed: _exportFile,
                              ),
                              const SizedBox(width: 10),
                              EditorRoundIconButton(
                                icon: Icons.search,
                                tooltip: 'Buscar',
                                onPressed: _showSearchSheet,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Content with fade-in + slight scale
                    Positioned.fill(
                      // Removing toolbar siblings must preserve the editor's
                      // state and its active connection to the keyboard.
                      key: const ValueKey('editor-workspace'),
                      top: compact ? (keyboardVisible ? 0 : 47) : 62,
                      bottom: contentBottom,
                      child: FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            EditorTab(
                              codeController: _codeController,
                              focusNode: _codeFocusNode,
                              keyboardVisible: keyboardVisible,
                            ),
                            const EditorWorkspacePanel(
                              fileName: 'tokens.json',
                              child: TokensTab(),
                            ),
                            const EditorWorkspacePanel(
                              fileName: 'ast.tree',
                              child: AstTab(),
                            ),
                            const EditorWorkspacePanel(
                              fileName: 'trace.log',
                              child: DebuggerTab(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom dock with slide-up entrance
                    if (showKeyboardShortcuts)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LumiKeyboardToolbar(
                          compact: compact,
                          onInsert: _insertShortcut,
                          onDismiss: _codeFocusNode.unfocus,
                        ),
                      ),
                    if (!keyboardVisible)
                      Positioned(
                        left: 7,
                        right: 7,
                        bottom: 0,
                        child: Transform.translate(
                          offset: Offset(0, _dockSlideAnimation.value),
                          child: FadeTransition(
                            opacity: _topBarFadeAnimation,
                            child: EditorDock(
                              selected:
                                  EditorPanel.values[_tabController.index],
                              isLoading: isLoading,
                              onSelect: (panel) =>
                                  _tabController.animateTo(panel.index),
                              onExecute: isLoading ? null : _runCompilation,
                              onSettings: () =>
                                  context.push(AppRoutes.settings),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          }),
        );
      }),
    );
  }
}
