import 'package:flutter/material.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/features/editor/domain/source_search.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';

/// Bottom sheet listing the starter templates.
class TemplatePickerSheet extends StatelessWidget {
  final ValueChanged<CodeTemplate> onSelected;

  const TemplatePickerSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        itemCount: EditorTemplates.templates.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
        itemBuilder: (context, index) {
          final template = EditorTemplates.templates[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              template.title,
              style: TextStyle(color: colors.text, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              template.description,
              style: TextStyle(color: colors.muted, fontSize: 12),
            ),
            onTap: () => onSelected(template),
          );
        },
      ),
    );
  }
}

/// Bottom sheet that counts occurrences of a text in [source].
class SourceSearchSheet extends StatefulWidget {
  final String source;

  const SourceSearchSheet({super.key, required this.source});

  @override
  State<SourceSearchSheet> createState() => _SourceSearchSheetState();
}

class _SourceSearchSheetState extends State<SourceSearchSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.editorColors;
    final query = _controller.text.trim();
    final matches = countOccurrences(widget.source, query);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color),
        );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: colors.text,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: colors.text),
              decoration: InputDecoration(
                hintText: 'Buscar no arquivo',
                hintStyle: TextStyle(color: colors.subtle),
                prefixIcon: Icon(Icons.search, color: colors.icon),
                filled: true,
                fillColor: colors.raised,
                border: border(colors.border),
                enabledBorder: border(colors.border),
                focusedBorder: border(colors.subtle),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                query.isEmpty
                    ? 'Digite para procurar.'
                    : '$matches ocorrencia(s) encontrada(s).',
                style: TextStyle(color: colors.muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
