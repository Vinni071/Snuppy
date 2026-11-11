import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/editor/presentation/widgets/console_panel.dart';
import 'package:luminthor/features/editor/presentation/widgets/editor_chrome.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_controller.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_editor.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

class EditorTab extends ConsumerStatefulWidget {
  final LumiCodeController codeController;
  final FocusNode focusNode;
  final bool keyboardVisible;

  const EditorTab({
    super.key,
    required this.codeController,
    required this.focusNode,
    required this.keyboardVisible,
  });

  @override
  ConsumerState<EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends ConsumerState<EditorTab> {
  @override
  Widget build(BuildContext context) {
    // Watch only what this tab renders: typing changes the source on every
    // keystroke, and the controller already holds the text.
    final highlightedLine =
        ref.watch(editorProvider.select((s) => s.currentStep?.line));
    final isDebugging = ref.watch(editorProvider.select((s) => s.isDebugging));
    final fontSize = ref.watch(settingsProvider.select((s) => s.fontSize));
    final notifier = ref.read(editorProvider.notifier);
    final fileName =
        ref.watch(workspaceProvider.select((w) => w.activeDocument?.name)) ??
            'Editor.lumi';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.editorColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.editorColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.editorColors.shadow,
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 300;
          return Column(
            children: [
              Offstage(
                offstage: compact,
                child: EditorWindowHeader(
                  fileName: fileName,
                  trailing: Tooltip(
                    message:
                        'Código salvo automaticamente no Luminthor. Use Exportar arquivo para salvar uma cópia no dispositivo.',
                    child: Icon(Icons.save_outlined,
                        size: 13, color: context.editorColors.subtle),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: compact
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                      : const EdgeInsets.fromLTRB(14, 18, 14, 14),
                  child: LumiCodeEditor(
                    controller: widget.codeController,
                    focusNode: widget.focusNode,
                    highlightedLine: highlightedLine,
                    style: AppTheme.editorTextStyle.copyWith(
                      fontSize: fontSize,
                      height: 1.48,
                      color: context.editorColors.text,
                    ),
                    onChanged: notifier.updateSource,
                    readOnly: isDebugging,
                  ),
                ),
              ),
              Offstage(
                offstage: widget.keyboardVisible,
                child: ConsolePanel(
                  contentHeight:
                      !widget.keyboardVisible && constraints.maxHeight < 500
                          ? (constraints.maxHeight * 0.4).clamp(80.0, 200.0)
                          : 200,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
