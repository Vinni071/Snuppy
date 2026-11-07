import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'home_components.dart';

enum HomeDockGlyph {
  home,
  folder,
  grid,
  route,
  code,
  tokens,
  tree,
  pulse,
  settings
}

class HomeDockItem {
  final String label;
  final HomeDockGlyph glyph;
  const HomeDockItem({required this.label, required this.glyph});
}

/// Floating bottom bar. On selection the new icon grows in
/// color, the previous one fades back to gray, and the items slide on a spring.
class HomeDock extends StatefulWidget {
  final HomePalette palette;
  final List<HomeDockItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Fixed-width widget placed before the item at [insertAt]; it takes no part
  /// in the selection or the sliding.
  final Widget? insert;
  final int insertAt;
  final double insertWidth;

  const HomeDock({
    super.key,
    required this.palette,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.insert,
    this.insertAt = 0,
    this.insertWidth = 0,
  });

  @override
  State<HomeDock> createState() => _HomeDockState();
}

class _HomeDockState extends State<HomeDock>
    with SingleTickerProviderStateMixin {
  static const _spring =
      SpringDescription(mass: 1, stiffness: 160, damping: 17);

  /// Share of the bar's width taken by the selected item; the extra room over
  /// an equal split is what makes the other items slide.
  static const _selectedShare = .29;

  late final AnimationController _motion =
      AnimationController.unbounded(vsync: this, value: 1);

  /// How selected each item was when the current motion started (0 to 1).
  late List<double> _start = [
    for (var i = 0; i < widget.items.length; i++)
      i == widget.selectedIndex ? 1.0 : 0.0
  ];
  bool _forward = true;

  @override
  void didUpdateWidget(HomeDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.selectedIndex;
    if (previous == widget.selectedIndex) return;
    // Starting from the current values keeps a tap mid-motion continuous.
    _start = [
      for (var i = 0; i < widget.items.length; i++) _presence(i, previous)
    ];
    _forward = widget.selectedIndex > previous;
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
    } else {
      _motion.animateWith(SpringSimulation(_spring, 0, 1, 0, snapToEnd: true));
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  double _presence(int index, int selected) =>
      lerpDouble(_start[index], index == selected ? 1 : 0, _motion.value)!;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: p.dock,
        borderRadius: BorderRadius.circular(100),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        // Keeps the outer labels clear of the pill's curved ends.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LayoutBuilder(builder: (context, constraints) {
            final slotsWidth = constraints.maxWidth -
                (widget.insert == null ? 0 : widget.insertWidth);
            final selectedWidth = slotsWidth * _selectedShare;
            final idleWidth =
                (slotsWidth - selectedWidth) / (widget.items.length - 1);
            return AnimatedBuilder(
              animation: _motion,
              builder: (context, _) => Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < widget.items.length; i++) ...[
                    if (widget.insert != null && i == widget.insertAt)
                      SizedBox(width: widget.insertWidth, child: widget.insert),
                    _slot(i, selectedWidth, idleWidth),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _slot(int index, double selectedWidth, double idleWidth) {
    final p = widget.palette;
    final item = widget.items[index];
    final selected = index == widget.selectedIndex;
    // Only the slot widths overshoot: the icon never grows past its size.
    final presence = _presence(index, widget.selectedIndex);
    final reveal = ((presence - .1) / .5).clamp(0.0, 1.0);
    final scale = selected || !_forward
        ? lerpDouble(.2, 1, presence.clamp(0.0, 1.0))!
        : 1.0;
    return SizedBox(
      width: lerpDouble(idleWidth, selectedWidth, presence),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        label: item.label,
        child: InkWell(
          key: ValueKey('home-dock-$index'),
          onTap: () => widget.onSelected(index),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: p.accentFill.withValues(alpha: .4),
          focusColor: p.accentFill.withValues(alpha: .7),
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 28,
                  child: Stack(fit: StackFit.expand, children: [
                    if (reveal < 1)
                      Opacity(
                        key: ValueKey('home-dock-idle-$index'),
                        opacity: 1 - reveal,
                        child: _DuotoneIcon(
                            glyph: item.glyph,
                            back: p.dockIdleBack,
                            front: p.dockIdle),
                      ),
                    if (reveal > 0)
                      Transform.scale(
                        key: ValueKey('home-dock-active-$index'),
                        scale: scale,
                        child: Opacity(
                          opacity: reveal,
                          child: _DuotoneIcon(
                              glyph: item.glyph,
                              back: p.dockActiveBack,
                              front: p.dockActive),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        color: p.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DuotoneIcon extends StatelessWidget {
  final HomeDockGlyph glyph;
  final Color back;
  final Color front;
  const _DuotoneIcon(
      {required this.glyph, required this.back, required this.front});

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: _DuotonePainter(glyph: glyph, back: back, front: front));
}

class _DuotonePainter extends CustomPainter {
  final HomeDockGlyph glyph;
  final Color back;
  final Color front;
  const _DuotonePainter(
      {required this.glyph, required this.back, required this.front});

  /// Each glyph is a dim back layer and a bright front layer on a 24x24 grid.
  static (Path, Path) _layers(HomeDockGlyph glyph) {
    Path boxes(List<Rect> rects, double radius) {
      final path = Path();
      for (final rect in rects) {
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      }
      return path;
    }

    Path polygon(List<Offset> points) => Path()..addPolygon(points, true);

    Rect box(double x, double y, double w, double h) =>
        Rect.fromLTWH(x, y, w, h);

    switch (glyph) {
      case HomeDockGlyph.home:
        return (
          Path()
            ..moveTo(12, 2.5)
            ..lineTo(22.5, 11.5)
            ..lineTo(19.5, 11.5)
            ..lineTo(19.5, 21.5)
            ..lineTo(4.5, 21.5)
            ..lineTo(4.5, 11.5)
            ..lineTo(1.5, 11.5)
            ..close(),
          boxes([box(8.5, 12.5, 7, 9)], 1.5),
        );
      case HomeDockGlyph.folder:
        return (
          boxes([box(2, 4, 9.5, 8), box(2, 6.5, 20, 12)], 2),
          boxes([box(2, 10.5, 20, 10)], 2.5),
        );
      case HomeDockGlyph.grid:
        return (
          boxes([box(13, 2.5, 8.5, 8.5), box(2.5, 13, 8.5, 8.5)], 2),
          boxes([box(2.5, 2.5, 8.5, 8.5), box(13, 13, 8.5, 8.5)], 2),
        );
      case HomeDockGlyph.code:
        return (
          boxes([box(2.5, 3.5, 19, 17)], 3.5),
          polygon(const [
            Offset(9.2, 7.6),
            Offset(10.8, 9.2),
            Offset(8, 12),
            Offset(10.8, 14.8),
            Offset(9.2, 16.4),
            Offset(4.8, 12),
          ])
            ..addPath(
                polygon(const [
                  Offset(14.8, 7.6),
                  Offset(19.2, 12),
                  Offset(14.8, 16.4),
                  Offset(13.2, 14.8),
                  Offset(16, 12),
                  Offset(13.2, 9.2),
                ]),
                Offset.zero),
        );
      case HomeDockGlyph.tokens:
        return (
          boxes([box(2.5, 4, 11.5, 7), box(10.5, 13, 11, 7)], 2.5),
          boxes([box(16, 4, 5.5, 7), box(2.5, 13, 6, 7)], 2.5),
        );
      case HomeDockGlyph.tree:
        return (
          boxes([
            box(11, 8, 2, 5),
            box(5, 11.5, 14, 2),
            box(5, 11.5, 2, 5),
            box(17, 11.5, 2, 5),
          ], 1),
          boxes([
            box(8, 2.5, 8, 6.5),
            box(2.5, 15, 7, 6.5),
            box(14.5, 15, 7, 6.5)
          ], 2),
        );
      case HomeDockGlyph.pulse:
        return (
          boxes([box(2.5, 3.5, 19, 17)], 3.5),
          polygon(const [
            Offset(5, 11),
            Offset(8.4, 11),
            Offset(11.1, 5.5),
            Offset(13.6, 13.5),
            Offset(14.9, 11),
            Offset(19, 11),
            Offset(19, 13),
            Offset(16.1, 13),
            Offset(13.4, 18.5),
            Offset(10.9, 10.5),
            Offset(9.6, 13),
            Offset(5, 13),
          ]),
        );
      case HomeDockGlyph.settings:
        return (
          boxes([box(2.5, 6, 19, 3), box(2.5, 15, 19, 3)], 1.5),
          Path()
            ..addOval(
                Rect.fromCircle(center: const Offset(15.5, 7.5), radius: 3.75))
            ..addOval(
                Rect.fromCircle(center: const Offset(8.5, 16.5), radius: 3.75)),
        );
      case HomeDockGlyph.route:
        return (
          boxes([
            box(6, 4.25, 13.75, 3.5),
            box(16.25, 4.25, 3.5, 9.5),
            box(4.25, 10.25, 15.5, 3.5),
            box(4.25, 10.25, 3.5, 9.5),
            box(4.25, 16.25, 13.75, 3.5),
          ], 1.75),
          Path()
            ..addOval(Rect.fromCircle(center: const Offset(6, 6), radius: 3.75))
            ..addOval(
                Rect.fromCircle(center: const Offset(18, 18), radius: 3.75)),
        );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (backPath, frontPath) = _layers(glyph);
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(backPath, Paint()..color = back);
    canvas.drawPath(frontPath, Paint()..color = front);
  }

  @override
  bool shouldRepaint(_DuotonePainter old) =>
      old.glyph != glyph || old.back != back || old.front != front;
}
