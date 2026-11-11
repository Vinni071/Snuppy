import 'package:flutter/material.dart';

/// Shrinks [child] while pressed and fires [onTap] on release.
///
/// Shared by the editor's dock, toolbar and debugger controls so they keep
/// the same tactile feedback.
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  /// Keeps the press feedback while [onTap] is null (e.g. a busy button that
  /// should still feel responsive).
  final bool animateWhenDisabled;

  const PressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.85,
    this.duration = const Duration(milliseconds: 100),
    this.animateWhenDisabled = false,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null || widget.animateWhenDisabled;
    return GestureDetector(
      onTapDown: interactive ? (_) => _controller.forward() : null,
      onTapUp: interactive
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: interactive ? _controller.reverse : null,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
