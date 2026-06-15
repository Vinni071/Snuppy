import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/editor_templates.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/editor_provider.dart';
import 'package:ide/features/settings/presentation/providers/settings_provider.dart';
import 'lumi_code_controller.dart';

class EditorTab extends ConsumerStatefulWidget {
  const EditorTab({super.key});

  @override
  ConsumerState<EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends ConsumerState<EditorTab> {
  late LumiCodeController _codeController;
  late ScrollController _textScrollController;
  late ScrollController _gutterScrollController;

  @override
  void initState() {
    super.initState();
    final initialCode = ref.read(editorProvider).source;
    _codeController = LumiCodeController(text: initialCode);
    _textScrollController = ScrollController();
    _gutterScrollController = ScrollController();

    // Sync scrolling of code field and line numbers gutter
    _textScrollController.addListener(_syncScroll);
  }

  void _syncScroll() {
    if (_gutterScrollController.hasClients) {
      _gutterScrollController.jumpTo(_textScrollController.offset);
    }
  }

  @override
  void dispose() {
    _textScrollController.removeListener(_syncScroll);
    _codeController.dispose();
    _textScrollController.dispose();
    _gutterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(editorProvider.notifier);

    // Sync editor text if it changes from provider (e.g. loaded template)
    if (_codeController.text != state.source) {
      _codeController.text = state.source;
    }

    // Determine current active line to highlight in debugger mode
    int? activeLine;
    if (state.isDebugging && state.compileResult != null) {
      final trace = state.compileResult!.executionTrace;
      if (state.currentStepIndex >= 0 && state.currentStepIndex < trace.length) {
        activeLine = trace[state.currentStepIndex].line;
      }
    }

    // Count lines of code
    final lineCount = '\n'.allMatches(_codeController.text).length + 1;

    return Column(
      children: [
        // ── Templates Row ──
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: AppColors.background,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: EditorTemplates.templates.length,
            itemBuilder: (context, index) {
              final template = EditorTemplates.templates[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(
                    template.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () {
                    notifier.updateSource(template.code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Carregado: ${template.title}'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        const Divider(),

        // ── Main Code Area with Line Numbers ──
        Expanded(
          child: Container(
            color: AppColors.surfaceDark,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Line Numbers Gutter
                Container(
                  width: 48,
                  padding: const EdgeInsets.only(top: 16),
                  color: AppColors.background,
                  child: ListView.builder(
                    controller: _gutterScrollController,
                    itemCount: lineCount,
                    itemBuilder: (context, index) {
                      final lineNum = index + 1;
                      final isActive = activeLine == lineNum;

                      return Container(
                        height: settings.fontSize * 1.5,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: isActive
                            ? const Icon(
                                Icons.play_arrow,
                                color: AppColors.secondary,
                                size: 14,
                              )
                            : Text(
                                '$lineNum',
                                style: AppTheme.editorTextStyle.copyWith(
                                  fontSize: settings.fontSize,
                                  color: AppColors.lineNumbers,
                                ),
                              ),
                      );
                    },
                  ),
                ),

                // Vertical divider
                Container(width: 1, color: AppColors.border),

                // Code Input Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                    child: SingleChildScrollView(
                      controller: _textScrollController,
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: AppTheme.editorTextStyle.copyWith(
                          fontSize: settings.fontSize,
                          color: const Color(0xFFF8F8F2),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: notifier.updateSource,
                        readOnly: state.isDebugging, // Disable edits while running debugger
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Error Banner Recaps ──
        if (state.compileResult != null && state.compileResult!.errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.error.withOpacity(0.15),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Encontrado ${state.compileResult!.errors.length} erro(s) de compilação. Abra o console abaixo para detalhes didáticos.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
