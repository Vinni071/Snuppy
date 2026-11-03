import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/learning_path.dart';
import '../providers/learning_provider.dart';
import 'learning_style.dart';

/// A continuous trail of raised islands and small stepping stones.
/// The artwork is drawn with the app's theme so it also works in dark mode.
class JourneyMap extends StatelessWidget {
  final LumiModule module;
  final int moduleIndex;
  final LearningProgress progress;
  final ValueChanged<LumiLesson> onOpen;

  const JourneyMap(
      {super.key,
      required this.module,
      required this.moduleIndex,
      required this.progress,
      required this.onOpen});

  static const _positions = [-.64, .64, -.24];

  @override
  Widget build(BuildContext context) {
    final c = LearningColors.of(context);
    final textScale = MediaQuery.textScalerOf(context);
    const nodeWidth = 156.0;
    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(
            text: text, style: DefaultTextStyle.of(context).style.merge(style)),
        textDirection: Directionality.of(context),
        textScaler: textScale,
      )..layout(maxWidth: nodeWidth);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final labelHeight = module.lessons
        .map((lesson) => measure(
            lesson.title,
            const TextStyle(
                fontSize: 12, height: 1.25, fontWeight: FontWeight.w700)))
        .reduce(math.max);
    final rowHeight = 142 +
        labelHeight +
        measure(
            'Concluída · revisar', const TextStyle(fontSize: 10, height: 1.3));
    return LayoutBuilder(builder: (context, constraints) {
      final points = [
        for (var i = 0; i < module.lessons.length; i++)
          Offset(
              constraints.maxWidth / 2 +
                  _positions[i] * (constraints.maxWidth - nodeWidth) / 2,
              i * rowHeight + 87),
      ];
      return CustomPaint(
        painter: _SteppingStones(
            points: points,
            colors: c,
            completed: module.lessons.map(progress.isCompleted).toList()),
        child: Column(children: [
          for (var i = 0; i < module.lessons.length; i++)
            SizedBox(
              height: rowHeight,
              child: Align(
                alignment: Alignment(_positions[i], -1),
                child: _JourneyStop(
                  lesson: module.lessons[i],
                  number: moduleIndex * 3 + i + 1,
                  seedling: moduleIndex == 0 && i == 0,
                  finalProject:
                      moduleIndex == LearningPath.modules.length - 1 && i == 2,
                  completed: progress.isCompleted(module.lessons[i]),
                  unlocked: progress.isUnlocked(module.lessons[i]),
                  current: progress.nextLesson == module.lessons[i],
                  onTap: () => onOpen(module.lessons[i]),
                ),
              ),
            ),
        ]),
      );
    });
  }
}

class _JourneyStop extends StatelessWidget {
  final LumiLesson lesson;
  final int number;
  final bool seedling;
  final bool finalProject;
  final bool completed;
  final bool unlocked;
  final bool current;
  final VoidCallback onTap;

  const _JourneyStop(
      {required this.lesson,
      required this.number,
      required this.seedling,
      required this.finalProject,
      required this.completed,
      required this.unlocked,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = LearningColors.of(context);
    return Semantics(
      button: true,
      label: 'Etapa $number. ${lesson.title}. '
          '${completed ? "Concluída" : unlocked ? "Disponível" : "Bloqueada"}. '
          '${lesson.minutes} minutos. ${lesson.xp} XP.',
      child: ExcludeSemantics(
        child: SizedBox(
          width: 156,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('lesson-${lesson.id}'),
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: 122,
                  width: 156,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned.fill(
                        child: CustomPaint(
                            painter: _IslandPainter(
                      colors: c,
                      unlocked: unlocked,
                      current: current,
                      kind: finalProject
                          ? _IslandKind.trophy
                          : lesson.isProject
                              ? _IslandKind.gift
                              : seedling
                                  ? _IslandKind.seedling
                                  : _IslandKind.terminal,
                    ))),
                    if (current)
                      Positioned(
                        top: 0,
                        left: 23,
                        right: 23,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          decoration: BoxDecoration(
                              color: c.action,
                              borderRadius: BorderRadius.circular(9)),
                          child: Text('COMEÇAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: c.onAction,
                                  fontSize: 9,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1)),
                        ),
                      ),
                    if (completed || !unlocked)
                      Positioned(
                        right: 18,
                        bottom: 17,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed ? c.action : c.surface,
                              border: Border.all(color: c.border)),
                          child: Icon(
                              completed
                                  ? Icons.check_rounded
                                  : Icons.lock_rounded,
                              size: 12,
                              color: completed ? c.onAction : c.muted),
                        ),
                      ),
                  ]),
                ),
                Text(lesson.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: unlocked ? c.text : c.muted,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    completed
                        ? 'Concluída · revisar'
                        : '${lesson.minutes} min · +${lesson.xp} XP',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: c.muted, fontSize: 10, height: 1.3)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flattened, rotated squares with a visible front edge, as in a game map.
void _plate(Canvas canvas, Offset center, double width, Color top, Color edge,
    {double depth = 5, bool inset = false}) {
  void face(Offset position, double size, Color color) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(1, .53);
    canvas.rotate(-.32);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: size, height: size),
            Radius.circular(size * .21)),
        Paint()..color = color);
    canvas.restore();
  }

  face(center + Offset(0, depth), width, edge);
  face(center, width, top);
  if (inset) {
    face(center, width * .76, Color.lerp(top, edge, .23)!);
    face(center + const Offset(-2, -2), width * .63, top);
  }
}

class _SteppingStones extends CustomPainter {
  final List<Offset> points;
  final List<bool> completed;
  final LearningColors colors;
  const _SteppingStones(
      {required this.points, required this.colors, required this.completed});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final direction = (end.dx - start.dx).sign;
      final path = Path()
        ..moveTo(start.dx + direction * 46, start.dy + 12)
        ..cubicTo(
            start.dx + direction * 120,
            start.dy + 40,
            end.dx - direction * 110,
            end.dy - 65,
            end.dx - direction * 46,
            end.dy - 12);
      final metric = path.computeMetrics().first;
      final top = completed[i] ? colors.accent : colors.palette.selection;
      final edge = completed[i]
          ? Color.lerp(colors.accent, colors.background, .4)!
          : Color.lerp(colors.border, colors.background, .4)!;
      for (final t in [.38, .62, .86]) {
        final point = metric.getTangentForOffset(metric.length * t)!.position;
        canvas.drawOval(
            Rect.fromCenter(
                center: point + const Offset(0, 7), width: 34, height: 14),
            Paint()
              ..color = colors.shadow
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        _plate(canvas, point, 29, top, edge, depth: 4);
        canvas.drawCircle(point + const Offset(-2, -1), 2,
            Paint()..color = completed[i] ? colors.accentLight : colors.border);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SteppingStones oldDelegate) =>
      oldDelegate.colors.dark != colors.dark ||
      !listEquals(oldDelegate.points, points) ||
      !listEquals(oldDelegate.completed, completed);
}

enum _IslandKind { seedling, terminal, gift, trophy }

class _IslandPainter extends CustomPainter {
  final LearningColors colors;
  final bool unlocked;
  final bool current;
  final _IslandKind kind;
  const _IslandPainter(
      {required this.colors,
      required this.unlocked,
      required this.current,
      required this.kind});

  Color get primary => unlocked ? colors.accent : colors.palette.selection;
  Color get light => unlocked
      ? colors.accentLight
      : Color.lerp(colors.palette.selection, colors.muted, .32)!;
  Color get secondary =>
      unlocked ? colors.secondary : colors.muted.withValues(alpha: .6);
  Color get depth => unlocked
      ? Color.lerp(colors.accent, colors.background, .45)!
      : Color.lerp(colors.palette.selection, colors.background, .25)!;

  void polygon(Canvas canvas, List<Offset> points, Color color) {
    canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 180, size.height / 160);
    if (unlocked) {
      const rect = Rect.fromLTWH(4, 78, 172, 82);
      canvas.drawOval(
          rect,
          Paint()
            ..shader = RadialGradient(colors: [
              primary.withValues(alpha: current ? .22 : .12),
              primary.withValues(alpha: 0)
            ]).createShader(rect));
      final beam = Path()
        ..moveTo(27, 116)
        ..lineTo(11, 160)
        ..lineTo(168, 160)
        ..lineTo(151, 116)
        ..close();
      canvas.drawPath(
          beam,
          Paint()
            ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primary.withValues(alpha: .14),
                  primary.withValues(alpha: 0)
                ]).createShader(const Rect.fromLTWH(0, 116, 180, 44)));
    }
    canvas.drawOval(
        const Rect.fromLTWH(24, 118, 139, 27),
        Paint()
          ..color = colors.shadow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
    _plate(canvas, const Offset(90, 117), 112, primary, depth,
        depth: 12, inset: true);
    switch (kind) {
      case _IslandKind.seedling:
        _seedling(canvas);
      case _IslandKind.terminal:
        _terminal(canvas);
      case _IslandKind.gift:
        _gift(canvas);
      case _IslandKind.trophy:
        _trophy(canvas);
    }
    canvas.restore();
  }

  void _seedling(Canvas canvas) {
    canvas.drawPath(
        Path()
          ..moveTo(61, 94)
          ..cubicTo(67, 129, 112, 129, 119, 94)
          ..close(),
        Paint()..color = depth);
    canvas.drawOval(
        const Rect.fromLTWH(61, 83, 58, 24), Paint()..color = light);
    canvas.drawOval(
        const Rect.fromLTWH(67, 87, 46, 15), Paint()..color = depth);
    canvas.drawPath(
        Path()
          ..moveTo(91, 94)
          ..cubicTo(83, 73, 99, 60, 92, 43),
        Paint()
          ..color = secondary
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        Path()
          ..moveTo(92, 65)
          ..cubicTo(98, 36, 127, 35, 137, 48)
          ..cubicTo(124, 68, 107, 72, 92, 65),
        Paint()..color = secondary);
    canvas.drawPath(
        Path()
          ..moveTo(88, 76)
          ..cubicTo(69, 45, 45, 51, 42, 63)
          ..cubicTo(52, 81, 72, 84, 88, 76),
        Paint()..color = light);
    canvas.drawPath(
        Path()
          ..moveTo(97, 62)
          ..quadraticBezierTo(110, 53, 127, 49),
        Paint()
          ..color = colors.surface.withValues(alpha: .45)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }

  void _terminal(Canvas canvas) {
    polygon(
        canvas,
        const [
          Offset(55, 43),
          Offset(123, 31),
          Offset(132, 38),
          Offset(132, 98),
          Offset(63, 110),
          Offset(55, 101)
        ],
        depth);
    polygon(
        canvas,
        const [
          Offset(55, 43),
          Offset(123, 31),
          Offset(123, 94),
          Offset(55, 106)
        ],
        light);
    polygon(
        canvas,
        const [
          Offset(62, 49),
          Offset(116, 40),
          Offset(116, 85),
          Offset(62, 95)
        ],
        unlocked ? colors.palette.surfaceDark : colors.background);
    final stroke = Paint()
      ..color = secondary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
        Path()
          ..moveTo(77, 60)
          ..lineTo(68, 71)
          ..lineTo(77, 77),
        stroke);
    canvas.drawPath(
        Path()
          ..moveTo(101, 56)
          ..lineTo(110, 64)
          ..lineTo(101, 74),
        stroke);
    canvas.drawLine(
        const Offset(94, 55),
        const Offset(85, 81),
        Paint()
          ..color = light
          ..strokeWidth = 3);
    canvas.drawCircle(const Offset(89, 96), 2, Paint()..color = depth);
  }

  void _gift(Canvas canvas) {
    final side = Color.lerp(secondary, colors.background, .25)!;
    polygon(
        canvas,
        const [Offset(55, 59), Offset(92, 77), Offset(92, 116), Offset(55, 97)],
        secondary);
    polygon(
        canvas,
        const [
          Offset(92, 77),
          Offset(132, 59),
          Offset(132, 99),
          Offset(92, 116)
        ],
        side);
    polygon(
        canvas,
        const [Offset(52, 51), Offset(93, 33), Offset(135, 51), Offset(92, 71)],
        secondary);
    polygon(
        canvas,
        const [Offset(52, 51), Offset(92, 71), Offset(92, 80), Offset(52, 61)],
        side);
    polygon(
        canvas,
        const [
          Offset(92, 71),
          Offset(135, 51),
          Offset(135, 61),
          Offset(92, 80)
        ],
        secondary);
    polygon(
        canvas,
        const [
          Offset(70, 60),
          Offset(81, 65),
          Offset(81, 111),
          Offset(70, 105)
        ],
        light);
    polygon(
        canvas,
        const [
          Offset(105, 65),
          Offset(117, 60),
          Offset(117, 106),
          Offset(105, 111)
        ],
        primary);
    polygon(
        canvas,
        const [
          Offset(69, 43),
          Offset(80, 38),
          Offset(117, 59),
          Offset(105, 65)
        ],
        light);
    polygon(
        canvas,
        const [
          Offset(70, 60),
          Offset(81, 65),
          Offset(118, 43),
          Offset(107, 38)
        ],
        primary);
    final ribbon = Paint()
      ..color = light
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(92, 46)
          ..cubicTo(49, 46, 70, 12, 92, 46)
          ..cubicTo(109, 8, 136, 33, 92, 46),
        ribbon);
  }

  void _trophy(Canvas canvas) {
    final handle = Paint()
      ..color = secondary
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawOval(const Rect.fromLTWH(45, 40, 35, 35), handle);
    canvas.drawOval(const Rect.fromLTWH(103, 40, 35, 35), handle);
    canvas.drawPath(
        Path()
          ..moveTo(62, 36)
          ..lineTo(120, 36)
          ..lineTo(113, 71)
          ..quadraticBezierTo(90, 101, 68, 71)
          ..close(),
        Paint()..color = light);
    canvas.drawPath(
        Path()
          ..moveTo(90, 36)
          ..lineTo(120, 36)
          ..lineTo(113, 71)
          ..quadraticBezierTo(102, 87, 90, 85)
          ..close(),
        Paint()..color = primary);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(86, 82, 10, 24), const Radius.circular(3)),
        Paint()..color = secondary);
    canvas.drawOval(
        const Rect.fromLTWH(68, 102, 45, 12), Paint()..color = light);
    canvas.drawCircle(const Offset(89, 60), 9, Paint()..color = secondary);
  }

  @override
  bool shouldRepaint(covariant _IslandPainter oldDelegate) =>
      oldDelegate.colors.dark != colors.dark ||
      oldDelegate.unlocked != unlocked ||
      oldDelegate.current != current ||
      oldDelegate.kind != kind;
}
