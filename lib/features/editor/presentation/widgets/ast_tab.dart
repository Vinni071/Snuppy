import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:ide/src/rust/api.dart';
import 'package:ide/src/rust/ast.dart';
import '../providers/editor_provider.dart';

class AstTab extends ConsumerWidget {
  const AstTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final result = state.compileResult;

    if (result == null) {
      return const Center(
        child: Text(
          'Execute o código primeiro para visualizar a AST.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    final ast = result.ast;

    if (ast == null) {
      return const Center(
        child: Text(
          'Nenhuma AST gerada (occorreu um erro de compilação).',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Header Stats
        const Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Árvore de Sintaxe Abstrata (AST)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                'Parser (Análise Sintática)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(),

        // AST Tree View
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AstNodeTreeWidget(node: ast, depth: 0),
          ),
        ),
      ],
    );
  }
}

class AstNodeTreeWidget extends StatefulWidget {
  final AstNodeView node;
  final int depth;

  const AstNodeTreeWidget({
    super.key,
    required this.node,
    required this.depth,
  });

  @override
  State<AstNodeTreeWidget> createState() => _AstNodeTreeWidgetState();
}

class _AstNodeTreeWidgetState extends State<AstNodeTreeWidget> {
  bool _isExpanded = true;

  Color _getNodeColor(String nodeType) {
    switch (nodeType.toLowerCase()) {
      case 'program':
        return AppColors.primary;
      case 'statement':
      case 'vardecl':
      case 'assignment':
      case 'print':
      case 'if':
      case 'while':
      case 'for':
      case 'fndecl':
      case 'return':
        return AppColors.tertiary;
      case 'expression':
      case 'binaryop':
      case 'unaryop':
      case 'call':
        return AppColors.secondary;
      case 'literal':
      case 'int':
      case 'float':
      case 'string':
      case 'bool':
      case 'null':
        return AppColors.syntaxLiteralInt;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;
    final nodeColor = _getNodeColor(widget.node.nodeType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node Header Card
        Padding(
          padding: EdgeInsets.only(left: widget.depth * 20.0),
          child: Row(
            children: [
              // Expand/Collapse arrow
              if (hasChildren)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Icon(
                    _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                    color: Colors.white70,
                    size: 20,
                  ),
                )
              else
                const SizedBox(width: 20),

              // Node content chip
              Expanded(
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Node Type tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: nodeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: nodeColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            widget.node.nodeType,
                            style: TextStyle(
                              color: nodeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Label
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              children: [
                                TextSpan(
                                  text: widget.node.label,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (widget.node.value != null) ...[
                                  const TextSpan(
                                    text: ' = ',
                                    style: TextStyle(color: AppColors.syntaxComment),
                                  ),
                                  TextSpan(
                                    text: widget.node.value,
                                    style: const TextStyle(
                                      color: AppColors.syntaxLiteralString,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Span coordinates
                        Text(
                          '[L${widget.node.span.line}:C${widget.node.span.column}]',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4B526D),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Recursive Children rendering
        if (hasChildren && _isExpanded)
          Column(
            children: widget.node.children
                .map((child) => AstNodeTreeWidget(
                      node: child,
                      depth: widget.depth + 1,
                    ))
                .toList(),
          ),
      ],
    );
  }
}
