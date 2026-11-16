import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/src/rust/ast.dart';

class AstTab extends ConsumerStatefulWidget {
  const AstTab({super.key});

  @override
  ConsumerState<AstTab> createState() => _AstTabState();
}

class _AstTabState extends ConsumerState<AstTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  Object? _lastResultIdentity;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final result = state.compileResult;

    if (result == null) {
      return Center(
        child: Text(
          'Execute o código primeiro para visualizar a AST.',
          style: TextStyle(color: context.editorColors.muted),
        ),
      );
    }

    // Trigger fade animation when result changes
    if (!identical(_lastResultIdentity, result)) {
      _lastResultIdentity = result;
      _fadeController.reset();
      _fadeController.forward();
    }

    final ast = result.ast;

    if (ast == null) {
      return Center(
        child: Text(
          'Nenhuma AST gerada (occorreu um erro de compilação).',
          style: TextStyle(color: context.editorColors.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Header Stats
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _fadeController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  'Árvore de Sintaxe Abstrata (AST)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.editorColors.text,
                  ),
                ),
                Text(
                  'Parser (Análise Sintática)',
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

        // AST Tree View
        Expanded(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _fadeController,
              curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AstNodeTreeWidget(node: ast, depth: 0),
            ),
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

class _AstNodeTreeWidgetState extends State<AstNodeTreeWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  Color _getNodeColor(String nodeType) {
    switch (nodeType.toLowerCase()) {
      case 'program':
        return context.editorColors.primary;
      case 'statement':
      case 'vardecl':
      case 'assignment':
      case 'print':
      case 'if':
      case 'while':
      case 'for':
      case 'fndecl':
      case 'return':
        return context.editorColors.tertiary;
      case 'expression':
      case 'binaryop':
      case 'unaryop':
      case 'call':
        return context.editorColors.secondary;
      case 'literal':
      case 'int':
      case 'float':
      case 'string':
      case 'bool':
      case 'null':
        return context.editorColors.syntaxLiteralInt;
      default:
        return context.editorColors.text;
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
              // Expand/Collapse arrow with smooth rotation
              if (hasChildren)
                GestureDetector(
                  onTap: _toggle,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: context.editorColors.icon,
                      size: 20,
                    ),
                  ),
                )
              else
                const SizedBox(width: 20),

              // Node content chip
              Expanded(
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: context.editorColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Node Type tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: nodeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: nodeColor.withValues(alpha: 0.4)),
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
                              style: TextStyle(
                                  fontSize: 13,
                                  color: context.editorColors.text),
                              children: [
                                TextSpan(
                                  text: widget.node.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (widget.node.value != null) ...[
                                  TextSpan(
                                    text: ' = ',
                                    style: TextStyle(
                                        color:
                                            context.editorColors.syntaxComment),
                                  ),
                                  TextSpan(
                                    text: widget.node.value,
                                    style: TextStyle(
                                      color: context
                                          .editorColors.syntaxLiteralString,
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
                          style: TextStyle(
                            fontSize: 10,
                            color: context.editorColors.subtle,
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

        // Animated recursive Children rendering
        if (hasChildren)
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: AlignmentDirectional.topStart,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Column(
                children: widget.node.children
                    .map((child) => AstNodeTreeWidget(
                          node: child,
                          depth: widget.depth + 1,
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
