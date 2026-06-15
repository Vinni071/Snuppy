import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'providers/editor_provider.dart';
import 'widgets/editor_tab.dart';
import 'widgets/tokens_tab.dart';
import 'widgets/ast_tab.dart';
import 'widgets/debugger_tab.dart';
import 'widgets/console_panel.dart';

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

    // Automatically navigate to debugger tab when debugger starts
    ref.listenManual(editorProvider, (previous, next) {
      if (next.isDebugging && !(_tabController.index == 3)) {
        _tabController.animateTo(3);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    final isCompilationSuccessful =
        state.compileResult != null && state.compileResult!.success;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.code, color: AppColors.secondary, size: 24),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'Snuppy',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'LUMI v0.1',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Run/Compile Button
            state.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.secondary),
                    ),
                  )
                : TextButton.icon(
                    onPressed: () async {
                      await notifier.runCompilation();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isCompilationSuccessful
                                  ? 'Compilação concluída com sucesso!'
                                  : 'Compilação falhou. Verifique os erros.',
                            ),
                            backgroundColor: isCompilationSuccessful
                                ? AppColors.success
                                : AppColors.error,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon:
                        const Icon(Icons.play_arrow, color: AppColors.success),
                    label: const Text('Executar',
                        style: TextStyle(color: AppColors.success)),
                  ),

            // Debug Button
            IconButton(
              icon: Icon(
                Icons.bug_report,
                color: isCompilationSuccessful
                    ? AppColors.secondary
                    : Colors.white30,
              ),
              onPressed:
                  isCompilationSuccessful ? notifier.startDebugging : null,
              tooltip: isCompilationSuccessful
                  ? 'Iniciar Depurador'
                  : 'Execute o código com sucesso primeiro',
            ),

            // Settings Button
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/settings'),
              tooltip: 'Configurações',
            ),
          ],
        ),
        body: Column(
          children: [
            // Tab Header (Visual files tab style)
            Container(
              color: AppColors.surfaceDark,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 16),
                        SizedBox(width: 6),
                        Text('editor.lumi', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list, size: 16),
                        SizedBox(width: 6),
                        Text('Tokens', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_tree, size: 16),
                        SizedBox(width: 6),
                        Text('AST', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bug_report, size: 16),
                        SizedBox(width: 6),
                        Text('Trace', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab view content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  EditorTab(),
                  TokensTab(),
                  AstTab(),
                  DebuggerTab(),
                ],
              ),
            ),

            // Console output panel
            const ConsolePanel(),
          ],
        ),
      ),
    );
  }
}
