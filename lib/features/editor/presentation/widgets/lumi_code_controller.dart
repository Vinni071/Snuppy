import 'package:flutter/material.dart';
import 'package:luminthor/app/theme/editor_palette.dart';

class LumiCodeController extends TextEditingController {
  LumiCodeController({super.text});

  void insertText(String insertion, {String suffix = ''}) {
    final current = value;
    final selection = current.selection;
    final hasSelection =
        selection.isValid && selection.end <= current.text.length;
    final start = hasSelection ? selection.start : current.text.length;
    final end = hasSelection ? selection.end : current.text.length;
    // Paired shortcuts wrap selected text. Other shortcuts replace it, just as
    // typing on the keyboard would.
    final selectedText =
        suffix.isEmpty ? '' : current.text.substring(start, end);
    final replacement = '$insertion$selectedText$suffix';

    value = TextEditingValue(
      text: current.text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(
        offset: start + insertion.length + selectedText.length,
      ),
    );
  }

  /// Replaces the text from [start] up to the cursor, leaving the cursor
  /// between [text] and [suffix].
  void replaceBeforeCursor(int start, String text, {String suffix = ''}) {
    final current = value;
    value = TextEditingValue(
      text: current.text
          .replaceRange(start, current.selection.end, '$text$suffix'),
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = <TextSpan>[];
    final textContent = text;

    // Define rules for token matches (order matters!)
    final patterns = [
      // Comments
      RegExp(r'//.*'),
      RegExp(r'/\*[\s\S]*?\*/'),
      // Strings
      RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"'),
      // Keywords
      RegExp(
        r'\b(?:var|const|if|else|while|for|fn|return|print|true|false|null|and|or|not|in|break|continue)\b',
      ),
      // Numbers
      RegExp(r'\b\d+(?:\.\d+)?\b'),
      // Identifiers / Operators (will fall back to default)
    ];

    // Combiner RegExp
    final combinedPattern = RegExp(
      patterns.map((p) => '(${p.pattern})').join('|'),
    );

    int lastMatchEnd = 0;

    combinedPattern.allMatches(textContent).forEach((match) {
      // Add plain text before match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: textContent.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      // Add highlighted match
      final matchText = match.group(0)!;
      TextStyle? matchStyle;

      if (match.group(1) != null || match.group(2) != null) {
        // Comments (LineComment or BlockComment)
        matchStyle = TextStyle(
            color: context.editorColors.syntaxComment,
            fontStyle: FontStyle.italic);
      } else if (match.group(3) != null) {
        // Strings
        matchStyle = TextStyle(color: context.editorColors.syntaxLiteralString);
      } else if (match.group(4) != null) {
        // Keywords
        matchStyle = TextStyle(
          color: context.editorColors.syntaxKeyword,
          fontWeight: FontWeight.bold,
        );
      } else if (match.group(5) != null) {
        // Numbers
        matchStyle = TextStyle(color: context.editorColors.syntaxLiteralInt);
      }

      spans.add(
        TextSpan(
          text: matchText,
          style: matchStyle ?? style,
        ),
      );

      lastMatchEnd = match.end;
    });

    // Add trailing plain text
    if (lastMatchEnd < textContent.length) {
      spans.add(
        TextSpan(
          text: textContent.substring(lastMatchEnd),
          style: style,
        ),
      );
    }

    return TextSpan(
      style: style,
      children: spans,
    );
  }
}
