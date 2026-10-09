import 'package:flutter/material.dart';

import '../../../../core/branding/luminthor_logo.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/workspace_colors.dart';

class HomePalette {
  final bool isDark;
  const HomePalette(this.isDark);

  Color get background =>
      isDark ? WorkspaceColors.background : WorkspaceColors.action;
  Color get panel => isDark ? WorkspaceColors.panel : Colors.white;
  Color get raised => isDark ? WorkspaceColors.raised : const Color(0xFFF0F0F0);
  Color get border => isDark ? WorkspaceColors.border : const Color(0xFFDDDDDD);
  Color get text => isDark ? WorkspaceColors.text : const Color(0xFF202020);
  Color get muted => isDark ? WorkspaceColors.muted : const Color(0xFF6B6B6B);
  Color get accent => isDark ? WorkspaceColors.icon : const Color(0xFF242424);
  Color get accentFill =>
      isDark ? WorkspaceColors.selection : const Color(0xFFE8E8E8);
  Color get dock => isDark ? WorkspaceColors.dock : Colors.white;
  Color get dockBorder =>
      isDark ? WorkspaceColors.dockBorder : const Color(0xFFD6D6D6);
  Color get button => isDark ? WorkspaceColors.action : text;
  Color get onButton => isDark ? WorkspaceColors.onAction : Colors.white;

  ThemeData theme(ThemeData base) => base.copyWith(
        scaffoldBackgroundColor: background,
        colorScheme: base.colorScheme.copyWith(
          primary: button,
          onPrimary: onButton,
          primaryContainer: accentFill,
          onPrimaryContainer: text,
          secondary: accent,
          onSecondary: background,
          secondaryContainer: accentFill,
          onSecondaryContainer: text,
          surface: panel,
          onSurface: text,
          onSurfaceVariant: muted,
          surfaceContainerHighest: raised,
          surfaceContainerHigh: panel,
          surfaceContainer: panel,
          surfaceContainerLow: panel,
          surfaceContainerLowest: background,
          surfaceTint: Colors.transparent,
          outline: border,
          outlineVariant: border,
        ),
        textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              backgroundColor: button, foregroundColor: onButton),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: accent),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: accent, side: BorderSide(color: border)),
        ),
        dialogTheme: base.dialogTheme.copyWith(
          backgroundColor: panel,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: border)),
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: raised,
          hintStyle: TextStyle(color: muted),
          labelStyle: TextStyle(color: muted),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: accent)),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: text,
          selectionColor: accent.withValues(alpha: .25),
          selectionHandleColor: text,
        ),
        navigationBarTheme: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? text : muted)),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              color: states.contains(WidgetState.selected) ? text : muted,
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500)),
        ),
        dividerTheme: base.dividerTheme.copyWith(color: border),
      );
}

class HomeTheme extends StatelessWidget {
  final Widget child;
  const HomeTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final palette = HomePalette(base.brightness == Brightness.dark);
    return Theme(data: palette.theme(base), child: child);
  }
}

class LuminthorBrand extends StatelessWidget {
  final HomePalette palette;
  const LuminthorBrand({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LuminthorLogo(
            isDark: palette.isDark,
            width: 34,
            part: LogoPart.symbol),
        const SizedBox(width: 9),
        Flexible(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: LuminthorLogo(
                    isDark: palette.isDark,
                    width: 135,
                    part: LogoPart.wordmark))),
      ],
    );
  }
}

class HomeCard extends StatelessWidget {
  final HomePalette palette;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const HomeCard(
      {super.key,
      required this.palette,
      required this.child,
      this.onTap,
      this.padding = const EdgeInsets.all(22),
      this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? palette.panel,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: palette.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: palette.accent.withValues(alpha: .07),
        splashColor: palette.accent.withValues(alpha: .1),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class HomeTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const HomeTag(
      {super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5)
        ],
        Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color))),
      ]),
    );
  }
}

class HomeActionCard extends StatelessWidget {
  final HomePalette palette;
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback? onTap;
  final bool compact;

  const HomeActionCard(
      {super.key,
      required this.palette,
      required this.icon,
      required this.title,
      required this.description,
      required this.accent,
      required this.onTap,
      this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
          color: accent.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: accent, size: 23),
    );
    final copy =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: TextStyle(
              color: palette.text, fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text(description,
          style: TextStyle(color: palette.muted, fontSize: 12, height: 1.5)),
    ]);
    return HomeCard(
      palette: palette,
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 16 : 22),
      child: compact
          ? Row(children: [
              iconWidget,
              const SizedBox(width: 16),
              Expanded(child: copy),
              Icon(Icons.arrow_forward_rounded, color: palette.muted, size: 18)
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                iconWidget,
                const Spacer(),
                Icon(Icons.arrow_forward_rounded,
                    color: palette.muted, size: 18)
              ]),
              const SizedBox(height: 20),
              copy,
            ]),
    );
  }
}

class LumiPreview extends StatelessWidget {
  final HomePalette palette;
  const LumiPreview({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    const codeStyle =
        TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.9);
    return Transform.rotate(
      angle: -.025,
      child: Container(
        width: 335,
        decoration: BoxDecoration(
          color: palette.panel,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(children: [
              for (var i = 0; i < 3; i++)
                Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.circle, size: 7, color: palette.border)),
              const SizedBox(width: 12),
              Text('primeiros-passos.lumi',
                  style: TextStyle(
                      color: palette.muted,
                      fontSize: 10,
                      fontFamily: 'monospace')),
              const Spacer(),
              Icon(Icons.code_rounded, color: palette.muted, size: 15),
            ]),
          ),
          Divider(height: 1, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 15, 18, 18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('1\n2\n3\n4\n5',
                  style: codeStyle.copyWith(
                      color: palette.muted.withValues(alpha: .5))),
              const SizedBox(width: 19),
              Expanded(
                  child: Text.rich(TextSpan(
                      style: codeStyle.copyWith(color: palette.text),
                      children: [
                    TextSpan(
                        text: '// Toda ideia tem um começo\n',
                        style: TextStyle(
                            color: palette.isDark
                                ? AppColors.syntaxComment
                                : palette.muted)),
                    TextSpan(
                        text: 'var ',
                        style: TextStyle(
                            color: palette.isDark
                                ? AppColors.syntaxKeyword
                                : palette.accent)),
                    const TextSpan(text: 'mensagem = '),
                    TextSpan(
                        text: '"Olá, mundo!"',
                        style: TextStyle(
                            color: palette.isDark
                                ? AppColors.syntaxLiteralString
                                : palette.text)),
                    const TextSpan(text: ';\n\n'),
                    TextSpan(
                        text: 'print',
                        style: TextStyle(
                            color: palette.isDark
                                ? AppColors.syntaxKeyword
                                : palette.accent)),
                    const TextSpan(text: '(mensagem);\n'),
                  ]))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.border))),
            child: Row(children: [
              Icon(Icons.terminal_rounded, size: 14, color: palette.muted),
              const SizedBox(width: 9),
              Text('Olá, mundo!',
                  style: codeStyle.copyWith(fontSize: 11, color: palette.text)),
              const Spacer(),
              HomeTag(label: 'Lumi', color: palette.accent)
            ]),
          ),
        ]),
      ),
    );
  }
}

class SidebarContent extends StatelessWidget {
  final Widget child;
  const SidebarContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
