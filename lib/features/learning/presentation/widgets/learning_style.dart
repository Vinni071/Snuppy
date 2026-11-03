import 'package:flutter/material.dart';
import '../../../../../core/theme/editor_palette.dart';

class LearningColors {
  final bool dark;
  const LearningColors(this.dark);

  EditorPalette get palette => EditorPalette(dark);

  Color get background => palette.background;
  Color get surface => palette.panel;
  Color get text => palette.text;
  Color get muted => palette.muted;
  Color get border => palette.border;
  Color get accent => palette.primary;
  Color get accentLight => palette.primaryLight;
  Color get secondary => palette.secondary;
  Color get action => palette.action;
  Color get onAction => palette.onAction;
  Color get tint => Color.alphaBlend(accent.withValues(alpha: .09), background);
  Color get locked => palette.raised;
  Color get shadow => palette.shadow;

  static LearningColors of(BuildContext context) =>
      LearningColors(Theme.of(context).brightness == Brightness.dark);
}

class LearningStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const LearningStat({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = LearningColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: c.accent),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: c.text, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }
}

ButtonStyle learningButtonStyle(LearningColors c) => FilledButton.styleFrom(
      backgroundColor: c.action,
      foregroundColor: c.onAction,
      minimumSize: const Size(48, 52),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
