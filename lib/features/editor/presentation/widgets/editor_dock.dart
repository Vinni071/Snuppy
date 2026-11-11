import 'package:flutter/material.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/shared/widgets/press_scale.dart';

/// Editor panels, in tab order.
enum EditorPanel { code, tokens, ast, trace }

/// Bottom dock: panel tabs, the Execute button and Settings.
class EditorDock extends StatelessWidget {
  final EditorPanel selected;
  final bool isLoading;
  final ValueChanged<EditorPanel> onSelect;
  final VoidCallback? onExecute;
  final VoidCallback onSettings;

  const EditorDock({
    super.key,
    required this.selected,
    required this.isLoading,
    required this.onSelect,
    required this.onExecute,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    Widget panelItem(EditorPanel panel, IconData icon, String label) =>
        Expanded(
          child: _DockItem(
            icon: icon,
            label: label,
            isSelected: selected == panel,
            onTap: () => onSelect(panel),
          ),
        );

    return Container(
      key: const ValueKey('editor-dock'),
      height: 62,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.dock,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: colors.dockBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          panelItem(EditorPanel.code, Icons.code, 'Editor'),
          panelItem(EditorPanel.tokens, Icons.data_object, 'Tokens'),
          panelItem(EditorPanel.ast, Icons.account_tree_outlined, 'AST'),
          panelItem(EditorPanel.trace, Icons.monitor_heart_outlined, 'Trace'),
          SizedBox(
            width: 72,
            child: _ExecuteDockButton(isLoading: isLoading, onTap: onExecute),
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

/// Dock item with tap bounce and animated selection (color, border, fill).
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
    final colors = context.editorColors;
    final foreground = isSelected ? colors.text : colors.subtle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 51,
          decoration: BoxDecoration(
            color: isSelected ? colors.selection : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(color: colors.subtle, width: 1.3)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey('${icon}_$isSelected'),
                  color: foreground,
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: foreground,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0,
                  ),
                  child: Text(label, maxLines: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Execute button: pulsating glow when idle, spinner while compiling.
class _ExecuteDockButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _ExecuteDockButton({required this.isLoading, required this.onTap});

  @override
  State<_ExecuteDockButton> createState() => _ExecuteDockButtonState();
}

class _ExecuteDockButtonState extends State<_ExecuteDockButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final Animation<double> _pulseAnimation = CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: PressScale(
        onTap: widget.onTap,
        pressedScale: 0.88,
        animateWhenDisabled: true,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          // The label and icon do not depend on the pulse; build them once.
          child: _ExecuteLabel(isLoading: widget.isLoading),
          builder: (context, child) {
            final glowOpacity =
                widget.isLoading ? 0.0 : 0.15 + 0.20 * _pulseAnimation.value;
            return Container(
              height: 51,
              decoration: BoxDecoration(
                color: colors.action,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: colors.action.withValues(alpha: glowOpacity),
                    blurRadius: 16 + 8 * _pulseAnimation.value,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _ExecuteLabel extends StatelessWidget {
  final bool isLoading;

  const _ExecuteLabel({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onAction,
                  ),
                )
              : Icon(
                  Icons.play_arrow,
                  key: const ValueKey('play'),
                  color: colors.onAction,
                  size: 24,
                ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Execute',
            maxLines: 1,
            style: TextStyle(
              color: colors.onAction,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
