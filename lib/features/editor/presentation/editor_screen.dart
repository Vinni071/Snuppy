import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/workspace_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/editor_templates.dart';
import '../../../core/constants/lumi_keyboard_shortcuts.dart';
import '../../home/data/workspace_file_service.dart';
import '../../home/presentation/providers/workspace_provider.dart';
import 'providers/editor_provider.dart';
import 'widgets/editor_tab.dart';
import 'widgets/tokens_tab.dart';
import 'widgets/ast_tab.dart';
import 'widgets/debugger_tab.dart';
import 'widgets/lumi_code_controller.dart';
import 'widgets/lumi_keyboard_toolbar.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

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
    _tabController = TabController(length: 4, vsync: this);
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

    // Automatically navigate to debugger tab when debugger starts
    ref.listenManual(editorProvider, (previous, next) {
      if (next.isDebugging && !(_tabController.index == 3)) {
        _tabController.animateTo(3);
      }
    });
  }

  void _refreshSelectedTab() {
    if (_tabController.index != 0) {
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
        ),
        backgroundColor: isSuccessful ? AppColors.success : AppColors.error,
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
    } catch (_) {
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
      backgroundColor: WorkspaceColors.panel,
      barrierColor: Colors.black54,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            itemCount: EditorTemplates.templates.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFF242424),
            ),
            itemBuilder: (context, index) {
              final template = EditorTemplates.templates[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  template.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  template.description,
                  style: const TextStyle(
                    color: WorkspaceColors.muted,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  final document = ref.read(workspaceProvider.notifier).create(
                        name: template.fileName,
                        source: template.code,
                        origin: 'Template · ${template.title}',
                      );
                  ref.read(editorProvider.notifier).openDocument(document);
                  _tabController.animateTo(0);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showSearchSheet() {
    _codeFocusNode.unfocus();
    final controller = TextEditingController();
    final source = ref.read(editorProvider).source;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WorkspaceColors.panel,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = controller.text.trim();
            final matches = query.isEmpty
                ? 0
                : RegExp(
                    RegExp.escape(query),
                    caseSensitive: false,
                  ).allMatches(source).length;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  MediaQuery.viewInsetsOf(context).bottom + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      cursorColor: Colors.white,
                      onChanged: (_) => setSheetState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar no arquivo',
                        hintStyle:
                            const TextStyle(color: WorkspaceColors.subtle),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFBDBDBD),
                        ),
                        filled: true,
                        fillColor: WorkspaceColors.raised,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: WorkspaceColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: WorkspaceColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: WorkspaceColors.subtle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        query.isEmpty
                            ? 'Digite para procurar.'
                            : '$matches ocorrencia(s) encontrada(s).',
                        style: const TextStyle(
                          color: WorkspaceColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compactEditing = keyboardVisible &&
        MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom <
            360;
    final showKeyboardShortcuts = keyboardVisible &&
        _codeFocusNode.hasFocus &&
        _tabController.index == 0 &&
        !state.isDebugging;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: WorkspaceColors.background,
        body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(11, 10, 11, 10),
          child: AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Top bar with fade-in
                  if (!compactEditing)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _topBarFadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _RoundIconButton(
                              icon: Icons.home_outlined,
                              tooltip: 'Voltar à Home',
                              onPressed: () => context.go('/'),
                            ),
                            const SizedBox(width: 10),
                            _RoundIconButton(
                              icon: Icons.menu,
                              tooltip: 'Modelos',
                              onPressed: _showTemplateSheet,
                            ),
                            const Spacer(),
                            _RoundIconButton(
                              icon: _exporting
                                  ? Icons.hourglass_top_rounded
                                  : Icons.file_download_outlined,
                              tooltip: 'Exportar arquivo',
                              onPressed: _exportFile,
                            ),
                            const SizedBox(width: 10),
                            _RoundIconButton(
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
                    top: compactEditing ? 0 : 62,
                    bottom: keyboardVisible ? 64 : 78,
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
                          const _WorkspacePanel(
                            fileName: 'tokens.json',
                            child: TokensTab(),
                          ),
                          const _WorkspacePanel(
                            fileName: 'ast.tree',
                            child: AstTab(),
                          ),
                          const _WorkspacePanel(
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
                          child: _BottomDock(
                            selectedIndex: _tabController.index,
                            isLoading: state.isLoading,
                            onSelect: (index) =>
                                _tabController.animateTo(index),
                            onExecute: state.isLoading ? null : _runCompilation,
                            onSettings: () => context.push('/settings'),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<_RoundIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WorkspaceColors.raised.withOpacity(0.72),
              border: Border.all(color: const Color(0xFF373737), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(widget.icon, color: WorkspaceColors.icon, size: 20),
          ),
        ),
      ),
    );
  }
}

class _WorkspacePanel extends StatelessWidget {
  final String fileName;
  final Widget child;

  const _WorkspacePanel({
    required this.fileName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: WorkspaceColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WorkspaceColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          _WindowHeader(fileName: fileName),
          Expanded(
            child: ColoredBox(
              color: WorkspaceColors.panel,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowHeader extends StatelessWidget {
  final String fileName;

  const _WindowHeader({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: const BoxDecoration(
        color: WorkspaceColors.header,
        border: Border(
          bottom: BorderSide(color: WorkspaceColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          const _WindowDot(),
          const SizedBox(width: 7),
          const _WindowDot(),
          const SizedBox(width: 7),
          const _WindowDot(),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: WorkspaceColors.subtle,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF343434),
        border: Border.all(color: const Color(0xFF454545), width: 0.7),
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  final int selectedIndex;
  final bool isLoading;
  final ValueChanged<int> onSelect;
  final VoidCallback? onExecute;
  final VoidCallback onSettings;

  const _BottomDock({
    required this.selectedIndex,
    required this.isLoading,
    required this.onSelect,
    required this.onExecute,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: WorkspaceColors.dock,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: WorkspaceColors.dockBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DockItem(
              icon: Icons.code,
              label: 'Editor',
              isSelected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.data_object,
              label: 'Tokens',
              isSelected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.account_tree_outlined,
              label: 'AST',
              isSelected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.monitor_heart_outlined,
              label: 'Trace',
              isSelected: selectedIndex == 3,
              onTap: () => onSelect(3),
            ),
          ),
          SizedBox(
            width: 72,
            child: _ExecuteDockButton(
              isLoading: isLoading,
              onTap: onExecute,
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              isSelected: false,
              onTap: onSettings,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated dock item with scale-bounce on tap and smooth animated transitions
/// for selection state (color, border, background).
class _DockItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) {
          _tapController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _tapController.reverse(),
        child: ScaleTransition(
          scale: _tapScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 51,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? WorkspaceColors.selection
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: widget.isSelected
                  ? Border.all(color: const Color(0xFF696969), width: 1.3)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon,
                    key: ValueKey('${widget.icon}_${widget.isSelected}'),
                    color: widget.isSelected
                        ? Colors.white
                        : const Color(0xFF7F7F7F),
                    size: 18,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : WorkspaceColors.subtle,
                      fontSize: 9,
                      fontWeight:
                          widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0,
                    ),
                    child: Text(widget.label, maxLines: 1),
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

/// Execute button with a pulsating glow animation when idle
/// and a spinning loader when compiling.
class _ExecuteDockButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _ExecuteDockButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_ExecuteDockButton> createState() => _ExecuteDockButtonState();
}

class _ExecuteDockButtonState extends State<_ExecuteDockButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();

    // Pulse glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tap bounce
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) {
          _tapController.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _tapController.reverse(),
        child: ScaleTransition(
          scale: _tapScale,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final glowOpacity =
                  widget.isLoading ? 0.0 : 0.15 + 0.20 * _pulseAnimation.value;
              return Container(
                height: 51,
                decoration: BoxDecoration(
                  color: WorkspaceColors.action,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(glowOpacity),
                      blurRadius: 16 + 8 * _pulseAnimation.value,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: widget.isLoading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.play_arrow,
                              key: ValueKey('play'),
                              color: Colors.black,
                              size: 24,
                            ),
                    ),
                    const SizedBox(height: 3),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Execute',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
