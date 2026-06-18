import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/editor_templates.dart';
import 'providers/editor_provider.dart';
import 'widgets/editor_tab.dart';
import 'widgets/tokens_tab.dart';
import 'widgets/ast_tab.dart';
import 'widgets/debugger_tab.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_refreshSelectedTab);

    // Automatically navigate to debugger tab when debugger starts
    ref.listenManual(editorProvider, (previous, next) {
      if (next.isDebugging && !(_tabController.index == 3)) {
        _tabController.animateTo(3);
      }
    });
  }

  void _refreshSelectedTab() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_refreshSelectedTab);
    _tabController.dispose();
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
              : 'Compilacao falhou. Verifique tokens, AST ou trace.',
        ),
        backgroundColor: isSuccessful ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTemplateSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111111),
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
                    color: Color(0xFF8A8A8A),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  ref.read(editorProvider.notifier).updateSource(template.code);
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
    final controller = TextEditingController();
    final source = ref.read(editorProvider).source;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111111),
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
                        hintStyle: const TextStyle(color: Color(0xFF777777)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFBDBDBD),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF303030),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF303030),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF777777),
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
                          color: Color(0xFF8A8A8A),
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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(11, 10, 11, 10),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundIconButton(
                      icon: Icons.menu,
                      tooltip: 'Modelos',
                      onPressed: _showTemplateSheet,
                    ),
                    _RoundIconButton(
                      icon: Icons.search,
                      tooltip: 'Buscar',
                      onPressed: _showSearchSheet,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 62,
                bottom: 78,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    EditorTab(),
                    _WorkspacePanel(
                      fileName: 'tokens.json',
                      child: TokensTab(),
                    ),
                    _WorkspacePanel(
                      fileName: 'ast.tree',
                      child: AstTab(),
                    ),
                    _WorkspacePanel(
                      fileName: 'trace.log',
                      child: DebuggerTab(),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 7,
                right: 7,
                bottom: 0,
                child: _BottomDock(
                  selectedIndex: _tabController.index,
                  isLoading: state.isLoading,
                  onSelect: (index) => _tabController.animateTo(index),
                  onExecute: state.isLoading ? null : _runCompilation,
                  onSettings: () => context.go('/settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A).withOpacity(0.72),
              border: Border.all(color: const Color(0xFF373737), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFD8D8D8), size: 20),
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
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF303030), width: 1.2),
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
              color: const Color(0xFF111111),
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
        color: Color(0xFF151515),
        border: Border(
          bottom: BorderSide(color: Color(0xFF282828), width: 1),
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
                color: Color(0xFF777777),
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
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFF3C3C3C), width: 1.2),
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

class _DockItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 51,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF303030) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(color: const Color(0xFF696969), width: 1.3)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF7F7F7F),
                  size: 18,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF777777),
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0,
                    ),
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

class _ExecuteDockButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _ExecuteDockButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 51,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                else
                  const Icon(Icons.play_arrow, color: Colors.black, size: 24),
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
          ),
        ),
      ),
    );
  }
}
