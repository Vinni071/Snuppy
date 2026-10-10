import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/editor_palette.dart';
import 'lumi_code_controller.dart';

/// Keeps source line numbers and the debug highlight aligned with wrapped text.
class LumiCodeEditor extends StatefulWidget {
  final LumiCodeController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final int? highlightedLine;

  const LumiCodeEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.onChanged,
    this.readOnly = false,
    this.highlightedLine,
  });

  @override
  State<LumiCodeEditor> createState() => _LumiCodeEditorState();
}

class _LumiCodeEditorState extends State<LumiCodeEditor> {
  final _scrollController = ScrollController();
  bool _needsReveal = true;
  Size? _viewport;

  @override
  void didUpdateWidget(covariant LumiCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightedLine != widget.highlightedLine ||
        oldWidget.style != widget.style) {
      _needsReveal = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealLine(Rect line, double viewportHeight) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      var target = position.pixels;
      if (line.top < target) {
        target = line.top;
      } else if (line.bottom > target + viewportHeight) {
        target = line.height > viewportHeight
            ? line.top
            : line.bottom - viewportHeight;
      }
      target = target.clamp(0.0, position.maxScrollExtent).toDouble();
      if (target != position.pixels) _scrollController.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final strut =
        StrutStyle.fromTextStyle(widget.style, forceStrutHeight: true);

    return LayoutBuilder(builder: (context, constraints) {
      final viewport = Size(constraints.maxWidth, constraints.maxHeight);
      if (_viewport != viewport) {
        _viewport = viewport;
        _needsReveal = true;
      }
      return AnimatedBuilder(
        animation: Listenable.merge([widget.controller, _scrollController]),
        builder: (context, _) {
          final source = widget.controller.text;
          final starts = <int>[0];
          for (var i = 0; i < source.length; i++) {
            if (source.codeUnitAt(i) == 10) starts.add(i + 1);
          }
          final numberPainter = TextPainter(
            text: TextSpan(text: '${starts.length}', style: widget.style),
            textDirection: TextDirection.ltr,
            textScaler: textScaler,
          )..layout();
          final gutterWidth = numberPainter.width + 20;
          numberPainter.dispose();

          // EditableText reserves 2px for the cursor and a 1px caret gap.
          final textWidth =
              math.max(0.0, constraints.maxWidth - gutterWidth - 3);
          final painter = TextPainter(
            text: widget.controller.buildTextSpan(
              context: context,
              style: widget.style,
              withComposing: true,
            ),
            textDirection: TextDirection.ltr,
            textScaler: textScaler,
            strutStyle: strut,
          )..layout(minWidth: textWidth, maxWidth: textWidth);
          final metrics = painter.computeLineMetrics();
          final rowHeight = metrics.isEmpty
              ? painter.preferredLineHeight
              : metrics.first.height;
          final tops = starts
              .map((offset) => painter
                  .getOffsetForCaret(
                    TextPosition(offset: offset),
                    Rect.zero,
                  )
                  .dy)
              .toList();
          final lines = List<Rect>.generate(starts.length, (index) {
            final bottom =
                index + 1 < tops.length ? tops[index + 1] : painter.height;
            return Rect.fromLTWH(0, tops[index], constraints.maxWidth,
                math.max(rowHeight, bottom - tops[index]));
          });
          painter.dispose();

          final selected = widget.highlightedLine;
          final selectedRect =
              selected != null && selected > 0 && selected <= lines.length
                  ? lines[selected - 1]
                  : null;
          if (_needsReveal && selectedRect != null) {
            _needsReveal = false;
            _revealLine(selectedRect, constraints.maxHeight);
          }
          final scrollOffset =
              _scrollController.hasClients ? _scrollController.offset : 0.0;

          return ClipRect(
            child: Stack(
              children: [
                if (selectedRect != null)
                  Positioned(
                    key: const ValueKey('debug-line-highlight'),
                    left: 0,
                    right: 0,
                    top: selectedRect.top - scrollOffset,
                    height: selectedRect.height,
                    child: IgnorePointer(
                      child: Semantics(
                        label: 'Linha $selected em depuração',
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.editorColors.secondary.withAlpha(31),
                            border: Border(
                              left: BorderSide(
                                  color: context.editorColors.secondary,
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Row(
                    children: [
                      SizedBox(width: gutterWidth),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          scrollController: _scrollController,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          cursorColor: context.editorColors.text,
                          textAlignVertical: TextAlignVertical.top,
                          textDirection: TextDirection.ltr,
                          style: widget.style,
                          strutStyle: strut,
                          decoration: InputDecoration(
                            hintText: '// Escreva seu código Lumi aqui...',
                            hintStyle:
                                TextStyle(color: context.editorColors.subtle),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: widget.onChanged,
                          readOnly: widget.readOnly,
                        ),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < lines.length; i++)
                  if (lines[i].top - scrollOffset < constraints.maxHeight &&
                      lines[i].top + rowHeight - scrollOffset > 0)
                    Positioned(
                      top: lines[i].top - scrollOffset,
                      left: 0,
                      width: gutterWidth - 10,
                      height: rowHeight,
                      child: IgnorePointer(
                        child: Text(
                          '${i + 1}',
                          key: ValueKey('editor-line-${i + 1}'),
                          textAlign: TextAlign.right,
                          style: widget.style.copyWith(
                            color: selected == i + 1
                                ? context.editorColors.secondary
                                : context.editorColors.subtle,
                          ),
                          strutStyle: strut,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      );
    });
  }
}
