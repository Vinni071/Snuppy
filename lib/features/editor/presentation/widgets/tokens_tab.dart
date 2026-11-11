import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';

class TokensTab extends ConsumerStatefulWidget {
  const TokensTab({super.key});

  @override
  ConsumerState<TokensTab> createState() => _TokensTabState();
}

class _TokensTabState extends ConsumerState<TokensTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  Object? _lastResultIdentity;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Color _getColorForTokenType(String type) {
    if (type.startsWith('Keyword')) return context.editorColors.syntaxKeyword;
    if (type.startsWith('Operator')) return context.editorColors.syntaxOperator;
    if (type.startsWith('Delimiter')) {
      return context.editorColors.syntaxDelimiter;
    }
    if (type.startsWith('Literal(integer)') ||
        type.startsWith('Literal(float)')) {
      return context.editorColors.syntaxLiteralInt;
    }
    if (type.startsWith('Literal(string)')) {
      return context.editorColors.syntaxLiteralString;
    }
    if (type.startsWith('Identifier')) {
      return context.editorColors.syntaxIdentifier;
    }
    if (type.startsWith('Comment')) return context.editorColors.syntaxComment;
    return context.editorColors.syntaxUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final result = state.compileResult;

    if (result == null) {
      return Center(
        child: Text(
          'Execute o código primeiro para visualizar os tokens.',
          style: TextStyle(color: context.editorColors.muted),
        ),
      );
    }

    // Trigger stagger animation when result changes
    if (!identical(_lastResultIdentity, result)) {
      _lastResultIdentity = result;
      _staggerController.reset();
      _staggerController.forward();
    }

    final tokens = result.tokens;

    if (tokens.isEmpty) {
      return Center(
        child: Text(
          'Nenhum token encontrado no código fornecido.',
          style: TextStyle(color: context.editorColors.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Header Stats — fade in
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fluxo de Tokens (${tokens.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.editorColors.text,
                  ),
                ),
                Text(
                  'Lexer (Análise Léxica)',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.editorColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // Token List — staggered slide-in
        Expanded(
          child: AnimatedBuilder(
            animation: _staggerController,
            builder: (context, _) {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: tokens.length,
                itemBuilder: (context, index) {
                  final token = tokens[index];
                  final color = _getColorForTokenType(token.tokenType);

                  // Stagger: each item slides in slightly later
                  final itemDelay = (index / tokens.length) * 0.5;
                  final itemEnd = (itemDelay + 0.5).clamp(0.0, 1.0);
                  final itemProgress = Interval(
                    itemDelay,
                    itemEnd,
                    curve: Curves.easeOutCubic,
                  ).transform(_staggerController.value);

                  return Transform.translate(
                    offset: Offset(30 * (1 - itemProgress), 0),
                    child: Opacity(
                      opacity: itemProgress,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: context.editorColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Line:Col indicator
                              Container(
                                width: 54,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.editorColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: context.editorColors.border,
                                      width: 1),
                                ),
                                child: Text(
                                  '${token.line}:${token.column}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: context.editorColors.muted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Lexeme (value)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      token.lexeme.replaceAll('\n', '\\n'),
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 14,
                                        color: context.editorColors.text,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      token.tokenType,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: color.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Colored Category Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.4),
                                      width: 1),
                                ),
                                child: Text(
                                  token.tokenType.split('(').first,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
