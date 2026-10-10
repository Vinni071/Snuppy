import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/editor_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/editor_provider.dart';
import 'package:luminthor/features/settings/presentation/providers/settings_provider.dart';
import 'console_panel.dart';
import 'lumi_code_controller.dart';
import 'lumi_code_editor.dart';
import '../../../home/presentation/providers/workspace_provider.dart';

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
    final state = ref.watch(editorProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(editorProvider.notifier);
    final fileName =
        ref.watch(workspaceProvider).activeDocument?.name ?? 'Editor.lumi';

    // Sync editor text if it changes from provider (e.g. loaded template)
    if (widget.codeController.text != state.source) {
      widget.codeController.text = state.source;
    }

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
                child: _EditorWindowHeader(fileName: fileName),
              ),
              Expanded(
                child: Padding(
                  padding: compact
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                      : const EdgeInsets.fromLTRB(14, 18, 14, 14),
                  child: LumiCodeEditor(
                    controller: widget.codeController,
                    focusNode: widget.focusNode,
                    highlightedLine: state.currentStep?.line,
                    style: AppTheme.editorTextStyle.copyWith(
                      fontSize: settings.fontSize,
                      height: 1.48,
                      color: context.editorColors.text,
                    ),
                    onChanged: notifier.updateSource,
                    readOnly: state.isDebugging,
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

class _EditorWindowHeader extends StatelessWidget {
  final String fileName;
  const _EditorWindowHeader({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: context.editorColors.header,
        border: Border(
          bottom: BorderSide(color: context.editorColors.divider, width: 1),
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
              style: TextStyle(
                color: context.editorColors.subtle,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          const Spacer(),
          Tooltip(
            message:
                'Código salvo automaticamente no Luminthor. Use Exportar arquivo para salvar uma cópia no dispositivo.',
            child: Icon(Icons.save_outlined,
                size: 13, color: context.editorColors.subtle),
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
        color: context.editorColors.windowDot,
        border:
            Border.all(color: context.editorColors.windowDotBorder, width: 0.7),
      ),
    );
  }
}
