import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:ide/src/rust/errors.dart';
import '../providers/editor_provider.dart';

class ConsolePanel extends ConsumerStatefulWidget {
  const ConsolePanel({super.key});

  @override
  ConsumerState<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends ConsumerState<ConsolePanel> {
  bool _isExpanded = true;
  int _activeTab = 0; // 0 = Output (Stdout), 1 = Diagnostics (Errors)

  Widget _buildErrorCard(BuildContext context, CompileError error, String source) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type & Coordinates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: typeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (line > 0)
                  Text(
                    'Linha $line, Coluna $col',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            // Erroneous Code Snippet & Gutter Visualizer
            if (lineSnippet != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lineSnippet,
                      style: AppTheme.editorTextStyle.copyWith(color: Colors.white70),
                    ),
                    // Draw carets under the column index
                    Text(
                      ' ' * (col - 1) + '^',
                      style: AppTheme.editorTextStyle.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
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
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],

            // semantic/typo suggestion
            if (suggestion != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Dica: $suggestion',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
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
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...callStack.map((frame) => Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 2),
                    child: Text(
                      '↳ em $frame',
                      style: const TextStyle(
                        color: AppColors.syntaxComment,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final result = state.compileResult;

    final hasErrors = result != null && result.errors.isNotEmpty;
    final outputText = result?.output ?? '';

    // Auto-switch tab to diagnostics if compilation failed with errors
    if (hasErrors && _activeTab == 0 && _isExpanded && result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeTab = 1;
          });
        }
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Console Header ──
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.surfaceDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Output Tab Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _activeTab = 0;
                            _isExpanded = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: _activeTab == 0
                                ? const Border(bottom: BorderSide(color: AppColors.success, width: 2))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.terminal,
                                size: 16,
                                color: _activeTab == 0 ? AppColors.success : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Saída do Console',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _activeTab == 0 ? Colors.white : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Diagnostics Tab Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _activeTab = 1;
                            _isExpanded = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: _activeTab == 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: hasErrors ? AppColors.error : AppColors.secondary,
                                      width: 2,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bug_report,
                                size: 16,
                                color: _activeTab == 1
                                    ? (hasErrors ? AppColors.error : AppColors.secondary)
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Erros & Diagnósticos',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _activeTab == 1 ? Colors.white : const Color(0xFF94A3B8),
                                ),
                              ),
                              if (hasErrors) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${result.errors.length}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),

          // ── Console Content ──
          if (_isExpanded)
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.surfaceDark,
              child: _activeTab == 0
                  ? _buildOutputTab(outputText, hasErrors)
                  : _buildDiagnosticsTab(result?.errors ?? [], state.source),
            ),
        ],
      ),
    );
  }

  Widget _buildOutputTab(String output, bool hasErrors) {
    if (output.isEmpty) {
      return Center(
        child: Text(
          hasErrors
              ? 'Erro de compilação. Nenhuma saída produzida.'
              : 'Nenhuma saída gerada. Clique em "Executar" para rodar o código.',
          style: const TextStyle(color: Color(0xFF6272A4), fontSize: 13),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SelectableText(
        output,
        style: AppTheme.consoleTextStyle.copyWith(color: AppColors.success),
      ),
    );
  }

  Widget _buildDiagnosticsTab(List<CompileError> errors, String source) {
    if (errors.isEmpty) {
      return const Center(
        child: Text(
          'Tudo limpo! Nenhum erro encontrado.',
          style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600),
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
