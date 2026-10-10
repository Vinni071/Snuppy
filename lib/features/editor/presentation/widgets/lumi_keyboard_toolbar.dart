import 'package:flutter/material.dart';

import '../../../../core/constants/lumi_keyboard_shortcuts.dart';
import '../../../../core/theme/editor_palette.dart';

class LumiKeyboardToolbar extends StatelessWidget {
  final ValueChanged<LumiKeyboardShortcut> onInsert;
  final VoidCallback onDismiss;
  final bool compact;

  const LumiKeyboardToolbar({
    super.key,
    required this.onInsert,
    required this.onDismiss,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Keep taps and scrolling inside the editor's input region so the keyboard
    // and selection stay active while using shortcuts.
    return TextFieldTapRegion(
      child: ExcludeFocus(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Material(
              color: context.editorColors.dock,
              surfaceTintColor: Colors.transparent,
              elevation: 8,
              shadowColor: context.editorColors.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.editorColors.dockBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: compact ? 48 : 56,
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            for (final shortcut in lumiKeyboardShortcuts)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: TextButton(
                                  key: ValueKey(
                                      'lumi-shortcut-${shortcut.label}'),
                                  onPressed: () => onInsert(shortcut),
                                  style: TextButton.styleFrom(
                                    foregroundColor: context.editorColors.text,
                                    backgroundColor:
                                        context.editorColors.raised,
                                    minimumSize: const Size(44, 44),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: Tooltip(
                                    message: shortcut.tooltip,
                                    child: Text(shortcut.label),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        width: 1,
                        color: context.editorColors.dockBorder,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Recolher teclado',
                      onPressed: onDismiss,
                      color: context.editorColors.icon,
                      icon: const Icon(Icons.keyboard_hide_outlined, size: 20),
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
