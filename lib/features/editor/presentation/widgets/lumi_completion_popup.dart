import 'package:flutter/material.dart';

import '../../../../core/theme/editor_palette.dart';
import '../../domain/lumi_completion.dart';

class LumiCompletionPopup extends StatefulWidget {
  /// Tall enough to be a comfortable touch target.
  static const itemExtent = 40.0;

  final List<LumiCompletion> items;
  final int selectedIndex;
  final ValueChanged<LumiCompletion> onSelected;

  const LumiCompletionPopup({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<LumiCompletionPopup> createState() => _LumiCompletionPopupState();
}

class _LumiCompletionPopupState extends State<LumiCompletionPopup> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant LumiCompletionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealSelected() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final top = widget.selectedIndex * LumiCompletionPopup.itemExtent;
    final bottom = top + LumiCompletionPopup.itemExtent;
    if (top < position.pixels) {
      _scrollController.jumpTo(top);
    } else if (bottom > position.pixels + position.viewportDimension) {
      _scrollController.jumpTo(bottom - position.viewportDimension);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    // Keep taps inside the editor's input region so the keyboard, the focus and
    // the cursor stay active when a suggestion is chosen.
    return TextFieldTapRegion(
      child: ExcludeFocus(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.5,
          child: Material(
            color: colors.dock,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
            shadowColor: colors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: colors.dockBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemExtent: LumiCompletionPopup.itemExtent,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return InkWell(
                  key: ValueKey('lumi-completion-${item.label}'),
                  onTap: () => widget.onSelected(item),
                  child: Container(
                    color:
                        index == widget.selectedIndex ? colors.selection : null,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.text,
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.subtle,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
