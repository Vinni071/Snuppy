import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:luminthor/src/rust/errors.dart';
import '../providers/editor_provider.dart';

class ConsolePanel extends ConsumerStatefulWidget {
  const ConsolePanel({super.key});

  @override
  ConsumerState<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends ConsumerState<ConsolePanel>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  int _activeTab = 0; // 0 = Output (Stdout), 1 = Diagnostics (Errors)
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    ref.listenManual(editorProvider, (previous, next) {
      final result = next.compileResult;
      if (result == null ||
          identical(previous?.compileResult, next.compileResult)) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _isExpanded = true;
        _activeTab = result.errors.isNotEmpty ? 1 : 0;
      });
      _expandController.forward();
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  Widget _buildErrorCard(
      BuildContext context, CompileError error, String source) {
    String typeLabel = '';
    Color typeColor = AppColors.error;
    String message = '';
    String? suggestion;
    List<String> expected = [];
    List<String> callStack = [];
    int line = 0;
    int col = 0;

    // Pattern match compile error fields
    if (error is CompileError_LexerError) {
      typeLabel = 'Erro Léxico';
      message = error.message;
      if (error.span != null) {
        line = error.span!.line;
        col = error.span!.column;
      }
    } else if (error is CompileError_ParserError) {
      typeLabel = 'Erro de Sintaxe';
      message = error.message;
      expected = error.expected;
      if (error.span != null) {
        line = error.span!.line;
        col = error.span!.column;
      }
    } else if (error is CompileError_SemanticError) {
      typeLabel = 'Erro Semântico';
      typeColor = AppColors.warning;
      message = error.message;
      suggestion = error.suggestion;
      if (error.span != null) {
        line = error.span!.line;
        col = error.span!.column;
      }
    } else if (error is CompileError_RuntimeError) {
      typeLabel = 'Erro de Execução';
      message = error.message;
      callStack = error.callStack;
      if (error.span != null) {
        line = error.span!.line;
        col = error.span!.column;
      }
    }

    // Attempt to extract the erroneous line from the source code for visualization
    String? lineSnippet;
    if (line > 0) {
      final lines = source.split('\n');
      if (line - 1 < lines.length) {
        lineSnippet = lines[line - 1];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: typeColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type & Coordinates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: typeColor.withOpacity(0.30)),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (line > 0)
                Text(
                  'Linha $line, Coluna $col',
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Erroneous Code Snippet & Gutter Visualizer
          if (lineSnippet != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF282828)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lineSnippet,
                    style: AppTheme.editorTextStyle
                        .copyWith(color: const Color(0xFFBBBBBB), fontSize: 12),
                  ),
                  // Draw carets under the column index
                  Text(
                    ' ' * (col - 1) + '^',
                    style: AppTheme.editorTextStyle.copyWith(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // parser expectation
          if (expected.isNotEmpty) ...[
            Text(
              'Esperado: ${expected.join(", ")}',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          // semantic/typo suggestion
          if (suggestion != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: AppColors.warning, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Dica: $suggestion',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // runtime callstack
          if (callStack.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Pilha de Chamadas (Rastreamento):',
              style: TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...callStack.map((frame) => Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 2),
                  child: Text(
                    '↳ em $frame',
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final result = state.compileResult;

    final hasErrors = result != null && result.errors.isNotEmpty;
    final outputText = result?.output ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        border: Border(
          top: BorderSide(color: Color(0xFF282828), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Console Header ──
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF131313),
              ),
              child: Row(
                children: [
                  // Tabs section
                  Expanded(
                    child: Row(
                      children: [
                        // Output Tab Button
                        _ConsoleTabButton(
                          icon: Icons.terminal,
                          label: 'Saída',
                          isActive: _activeTab == 0,
                          activeColor: AppColors.success,
                          onTap: () {
                            setState(() {
                              _activeTab = 0;
                              _isExpanded = true;
                            });
                            _expandController.forward();
                          },
                        ),
                        const SizedBox(width: 6),

                        // Diagnostics Tab Button
                        _ConsoleTabButton(
                          icon: Icons.bug_report,
                          label: 'Diagnósticos',
                          isActive: _activeTab == 1,
                          activeColor: hasErrors
                              ? AppColors.error
                              : AppColors.secondary,
                          badge: hasErrors ? result.errors.length : null,
                          onTap: () {
                            setState(() {
                              _activeTab = 1;
                              _isExpanded = true;
                            });
                            _expandController.forward();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF555555),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Console Content ──
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Container(
              height: 200,
              width: double.infinity,
              color: const Color(0xFF0D0D0D),
              child: _activeTab == 0
                  ? _buildOutputTab(outputText, hasErrors)
                  : _buildDiagnosticsTab(result?.errors ?? [], state.source),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputTab(String output, bool hasErrors) {
    if (output.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasErrors ? Icons.error_outline : Icons.terminal,
              color: const Color(0xFF333333),
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              hasErrors
                  ? 'Erro de compilação. Nenhuma saída produzida.'
                  : 'Nenhuma saída gerada.\nClique em "Execute" para rodar o código.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF484848),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: SelectableText(
        output,
        style: AppTheme.consoleTextStyle.copyWith(
          color: AppColors.success,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDiagnosticsTab(List<CompileError> errors, String source) {
    if (errors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(height: 10),
            const Text(
              'Tudo limpo! Nenhum erro encontrado.',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: errors.length,
      itemBuilder: (context, index) {
        return _buildErrorCard(context, errors[index], source);
      },
    );
  }
}

/// A tab button widget that matches the app's pill-style dark aesthetic.
class _ConsoleTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final int? badge;
  final VoidCallback onTap;

  const _ConsoleTabButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? activeColor.withOpacity(0.25)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isActive ? activeColor : const Color(0xFF555555),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFFD8D8D8)
                      : const Color(0xFF555555),
                  letterSpacing: 0,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
