import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/workspace_colors.dart';

/// Surfaces and syntax colors with readable contrast in each editor theme.
class EditorPalette {
  final bool isDark;

  const EditorPalette(this.isDark);

  Color get background =>
      isDark ? WorkspaceColors.background : const Color(0xFFF5F6F8);
  Color get panel => isDark ? WorkspaceColors.panel : Colors.white;
  Color get header => isDark ? WorkspaceColors.header : const Color(0xFFF1F2F4);
  Color get raised => isDark ? WorkspaceColors.raised : const Color(0xFFEEEFF2);
  Color get dock => isDark ? WorkspaceColors.dock : Colors.white;
  Color get selection =>
      isDark ? WorkspaceColors.selection : const Color(0xFFE4E7ED);
  Color get border => isDark ? WorkspaceColors.border : const Color(0xFFD1D5DB);
  Color get divider =>
      isDark ? WorkspaceColors.divider : const Color(0xFFE2E5EA);
  Color get dockBorder =>
      isDark ? WorkspaceColors.dockBorder : const Color(0xFFCBD1DA);
  Color get text => isDark ? WorkspaceColors.text : const Color(0xFF202124);
  Color get muted => isDark ? WorkspaceColors.muted : const Color(0xFF616875);
  Color get icon => isDark ? WorkspaceColors.icon : const Color(0xFF3D4654);
  Color get subtle => isDark ? WorkspaceColors.subtle : const Color(0xFF666B76);
  Color get action => isDark ? WorkspaceColors.action : const Color(0xFF242424);
  Color get onAction => isDark ? WorkspaceColors.onAction : Colors.white;
  Color get shadow => Color(isDark ? 0x73000000 : 0x14000000);
  Color get windowDot => Color(isDark ? 0xFF343434 : 0xFFD5D8DE);
  Color get windowDotBorder => Color(isDark ? 0xFF454545 : 0xFFB8BEC8);

  Color get surface => isDark ? AppColors.surface : panel;
  Color get surfaceDark =>
      isDark ? AppColors.surfaceDark : const Color(0xFFF8F9FB);
  Color get surfaceLight => isDark ? AppColors.surfaceLight : raised;
  Color get console => Color(isDark ? 0xFF0D0D0D : 0xFFFAFBFC);
  Color get consoleHeader => Color(isDark ? 0xFF131313 : 0xFFF1F2F4);
  Color get consoleCard => Color(isDark ? 0xFF161616 : 0xFFFFFFFF);

  Color get primary => isDark ? AppColors.primary : const Color(0xFF6941C6);
  Color get primaryLight =>
      isDark ? AppColors.primaryLight : const Color(0xFF6941C6);
  Color get secondary => isDark ? AppColors.secondary : const Color(0xFF006A7A);
  Color get onSecondary => isDark ? AppColors.background : Colors.white;
  Color get tertiary => isDark ? AppColors.tertiary : const Color(0xFFAA1766);
  Color get success => isDark ? AppColors.success : const Color(0xFF147A3B);
  Color get error => isDark ? AppColors.error : const Color(0xFFB4232F);
  Color get warning => isDark ? AppColors.warning : const Color(0xFF8B5700);
  Color get onStatus => isDark ? WorkspaceColors.background : Colors.white;

  Color get syntaxKeyword =>
      isDark ? AppColors.syntaxKeyword : const Color(0xFFA12D6A);
  Color get syntaxOperator =>
      isDark ? AppColors.syntaxOperator : const Color(0xFF167145);
  Color get syntaxDelimiter => isDark ? AppColors.syntaxDelimiter : text;
  Color get syntaxLiteralInt =>
      isDark ? AppColors.syntaxLiteralInt : const Color(0xFF693AC2);
  Color get syntaxLiteralString =>
      isDark ? AppColors.syntaxLiteralString : const Color(0xFF3C6A1E);
  Color get syntaxLiteralBool =>
      isDark ? AppColors.syntaxLiteralBool : const Color(0xFF9A4D00);
  Color get syntaxLiteralNull =>
      isDark ? AppColors.syntaxLiteralNull : const Color(0xFF006B7A);
  Color get syntaxIdentifier =>
      isDark ? AppColors.syntaxIdentifier : const Color(0xFF006B7A);
  Color get syntaxComment =>
      isDark ? AppColors.syntaxComment : const Color(0xFF586479);
  Color get syntaxUnknown => isDark ? AppColors.syntaxUnknown : error;
}

extension EditorThemeContext on BuildContext {
  EditorPalette get editorColors =>
      EditorPalette(Theme.of(this).brightness == Brightness.dark);
}
