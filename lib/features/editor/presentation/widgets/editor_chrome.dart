import 'package:flutter/material.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/shared/widgets/press_scale.dart';

/// Circular toolbar button used in the editor's top bar.
class EditorRoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const EditorRoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    return PressScale(
      onTap: onPressed,
      pressedScale: 0.88,
      duration: const Duration(milliseconds: 120),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.raised.withValues(alpha: 0.72),
            border: Border.all(color: colors.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: colors.icon, size: 20),
        ),
      ),
    );
  }
}

/// Rounded "window" that frames the token, AST and trace panels.
class EditorWorkspacePanel extends StatelessWidget {
  final String fileName;
  final Widget child;

  const EditorWorkspacePanel({
    super.key,
    required this.fileName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          EditorWindowHeader(fileName: fileName),
          Expanded(child: ColoredBox(color: colors.panel, child: child)),
        ],
      ),
    );
  }
}

/// Window title bar with three dots, a file name and an optional [trailing].
class EditorWindowHeader extends StatelessWidget {
  final String fileName;
  final Widget? trailing;

  const EditorWindowHeader({super.key, required this.fileName, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    final trailing = this.trailing;
    final title = Text(
      fileName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colors.subtle,
        fontSize: 11,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: colors.header,
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Row(
        children: [
          const _WindowDot(),
          const SizedBox(width: 7),
          const _WindowDot(),
          const SizedBox(width: 7),
          const _WindowDot(),
          const SizedBox(width: 15),
          if (trailing == null)
            Flexible(child: title)
          else ...[
            Expanded(child: title),
            trailing,
          ],
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot();

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.windowDot,
        border: Border.all(color: colors.windowDotBorder, width: 0.7),
      ),
    );
  }
}
