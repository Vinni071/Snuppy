import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/app/theme/editor_palette.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/shared/widgets/press_scale.dart';
import 'package:luminthor/src/rust/interpreter/environment.dart';

class DebuggerTab extends ConsumerStatefulWidget {
  const DebuggerTab({super.key});

  @override
  ConsumerState<DebuggerTab> createState() => _DebuggerTabState();
}

class _DebuggerTabState extends ConsumerState<DebuggerTab>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _stepTransitionController;
  late Animation<double> _stepFadeAnimation;
  late Animation<Offset> _stepSlideAnimation;
  int? _lastStepIndex;

  @override
  void initState() {
    super.initState();

    // Pulsing icon for the start screen
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Step transition animation
    _stepTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _stepFadeAnimation = CurvedAnimation(
      parent: _stepTransitionController,
      curve: Curves.easeOut,
    );

    _stepSlideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stepTransitionController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stepTransitionController.dispose();
    super.dispose();
  }

  void _triggerStepAnimation(int stepIndex) {
    if (_lastStepIndex != stepIndex) {
      _lastStepIndex = stepIndex;
      _stepTransitionController.reset();
      _stepTransitionController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final result = state.compileResult;

    if (result == null) {
      return Center(
        child: Text(
          'Execute o código primeiro para iniciar o depurador didático.',
          style: TextStyle(color: context.editorColors.muted),
        ),
      );
    }

    final trace = result.executionTrace;

    if (trace.isEmpty) {
      return Center(
        child: Text(
          'A execução não gerou passos (provavelmente ocorreu um erro).',
          style: TextStyle(color: context.editorColors.muted),
        ),
      );
    }

    // If not in debugging mode, show the "Start Debugger" screen
    if (!state.isDebugging) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing bug icon
            ScaleTransition(
              scale: _pulseAnimation,
              child: Icon(
                Icons.bug_report_outlined,
                size: 64,
                color: context.editorColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Depurador Didático Visual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.editorColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Explore a execução do seu programa passo a passo. Observe como as variáveis mudam na memória, como o escopo isola os dados e acompanhe a pilha de chamadas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.editorColors.muted),
              ),
            ),
            const SizedBox(height: 24),
            _AnimatedDebugButton(
              onPressed: notifier.startDebugging,
            ),
          ],
        ),
      );
    }

    final stepIndex = state.currentStepIndex;
    final step = state.currentStep;
    if (step == null) return const SizedBox.shrink();

    // Trigger step transition
    _triggerStepAnimation(stepIndex);

    return Column(
      children: [
        // ── Debugger Toolbar ──
        Container(
          color: context.editorColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Passo ${stepIndex + 1} de ${trace.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.editorColors.text,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Backward step
                      _DebugControlButton(
                        icon: Icons.arrow_back,
                        tooltip: 'Voltar um passo',
                        color: context.editorColors.secondary,
                        onPressed: stepIndex > 0 ? notifier.stepBackward : null,
                      ),
                      // Forward step
                      _DebugControlButton(
                        icon: Icons.arrow_forward,
                        tooltip: 'Avançar um passo',
                        color: context.editorColors.secondary,
                        onPressed: stepIndex < trace.length - 1
                            ? notifier.stepForward
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Stop debugging
                      _DebugControlButton(
                        icon: Icons.close,
                        tooltip: 'Parar depuração',
                        color: context.editorColors.error,
                        onPressed: notifier.stopDebugging,
                      ),
                    ],
                  ),
                ],
              ),
              // Timeline scrubber
              Slider(
                value: stepIndex.toDouble(),
                min: 0,
                max: trace.length > 1 ? (trace.length - 1).toDouble() : 1,
                divisions: trace.length > 1 ? trace.length - 1 : null,
                activeColor: context.editorColors.secondary,
                onChanged: trace.length > 1
                    ? (val) => notifier.goToStep(val.toInt())
                    : null,
              ),
            ],
          ),
        ),

        const Divider(),

        // ── Active Step Panel with animated transition ──
        SlideTransition(
          position: _stepSlideAnimation,
          child: FadeTransition(
            opacity: _stepFadeAnimation,
            child: Container(
              color: context.editorColors.surfaceLight.withValues(alpha: 0.4),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.editorColors.secondary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: context.editorColors.secondary
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          _actionLabel(step.action).toUpperCase(),
                          style: TextStyle(
                            color: context.editorColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Text(
                        'Linha ${step.line}, Coluna ${step.column}',
                        style: TextStyle(
                          color: context.editorColors.muted,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: TextStyle(
                      color: context.editorColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Divider(),

        // ── Memory & Environment Visualizer ──
        Expanded(
          child: FadeTransition(
            opacity: _stepFadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Variable Inspector
                Text(
                  'Estado da Memória (Variáveis por Escopo)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final scope in step.scopes)
                  _buildVariableInspector(context, scope),
                const SizedBox(height: 16),

                // Call Stack
                _buildCallStackVisualizer(
                    context, step.callStack, step.scopeDepth),
                const SizedBox(height: 16),

                // Step Output Console
                _buildStepConsole(context, state.visibleOutput),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _actionLabel(String action) =>
      const {
        'var_decl': 'Declaração de variável',
        'assignment': 'Atribuição',
        'if_eval': 'Condição de if',
        'while_check': 'Condição de while',
        'for_iter': 'Iteração de for',
        'fn_decl': 'Declaração de função',
        'fn_call': 'Chamada de função',
        'return': 'Retorno',
        'print': 'Impressão',
        'break': 'Saída da repetição',
        'continue': 'Próxima iteração',
      }[action] ??
      action;

  Widget _buildVariableInspector(BuildContext context, ScopeSnapshot scope) {
    final variables = scope.variables;
    final names = variables.keys.toList()..sort();
    final label = scope.depth == 0
        ? 'Escopo global'
        : scope.isFunctionScope
            ? 'Escopo de função (nível ${scope.depth})'
            : 'Escopo de bloco (nível ${scope.depth})';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory,
                    color: context.editorColors.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (variables.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhuma variável declarada neste escopo.',
                  style: TextStyle(
                      color: context.editorColors.syntaxComment, fontSize: 13),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2), // name
                  1: FlexColumnWidth(3), // value
                  2: FlexColumnWidth(1.5), // type
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                      color: context.editorColors.border, width: 0.5),
                ),
                children: names.map((name) {
                  final val = variables[name]!;

                  // Get type and value representation
                  String typeName = '';
                  String displayVal = '';
                  Color valColor = context.editorColors.text;

                  val.when(
                    int: (i) {
                      typeName = 'inteiro';
                      displayVal = '$i';
                      valColor = context.editorColors.syntaxLiteralInt;
                    },
                    float: (f) {
                      typeName = 'decimal';
                      displayVal = '$f';
                      valColor = context.editorColors.syntaxLiteralInt;
                    },
                    string: (s) {
                      typeName = 'texto';
                      displayVal = '"$s"';
                      valColor = context.editorColors.syntaxLiteralString;
                    },
                    bool: (b) {
                      typeName = 'booleano';
                      displayVal = '$b';
                      valColor = context.editorColors.syntaxLiteralBool;
                    },
                    null_: () {
                      typeName = 'nulo';
                      displayVal = 'null';
                      valColor = context.editorColors.syntaxLiteralNull;
                    },
                    function: (name, params, bodyIndex) {
                      typeName = 'função';
                      displayVal = '$name(${params.join(", ")})';
                      valColor = context.editorColors.primaryLight;
                    },
                  );

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: context.editorColors.text,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: valColor,
                          ),
                          child: Text(displayVal),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.editorColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: context.editorColors.muted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallStackVisualizer(
    BuildContext context,
    List<String> callStack,
    int scopeDepth,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers,
                    color: context.editorColors.primaryLight, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilha de Chamadas & Escopo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Call stack frames list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: callStack.isEmpty ? 1 : callStack.length,
              itemBuilder: (context, index) {
                final frame = callStack.isEmpty
                    ? 'global'
                    : callStack[callStack.length - 1 - index];
                final isTopFrame = index == 0;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isTopFrame
                        ? context.editorColors.primary.withValues(alpha: 0.12)
                        : context.editorColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isTopFrame
                          ? context.editorColors.primary
                          : context.editorColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_right_alt,
                              color: isTopFrame
                                  ? context.editorColors.primary
                                  : context.editorColors.subtle,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                frame == 'global' ? '🌐 <global>' : '📞 $frame',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: isTopFrame
                                      ? context.editorColors.text
                                      : context.editorColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isTopFrame)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.editorColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Profundidade: $scopeDepth',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepConsole(BuildContext context, String? output) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.terminal,
                    color: context.editorColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saída do Console (Acumulada)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.editorColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.editorColors.border),
              ),
              constraints: const BoxConstraints(minHeight: 60, maxHeight: 150),
              child: SingleChildScrollView(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTheme.consoleTextStyle.copyWith(
                    color: (output == null || output.isEmpty)
                        ? context.editorColors.syntaxComment
                        : context.editorColors.success,
                  ),
                  child: Text(
                    (output == null || output.isEmpty)
                        ? '[Saída de console vazia neste passo]'
                        : output,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated "Start Debugging" button with a shimmer/glow effect
class _AnimatedDebugButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedDebugButton({required this.onPressed});

  @override
  State<_AnimatedDebugButton> createState() => _AnimatedDebugButtonState();
}

class _AnimatedDebugButtonState extends State<_AnimatedDebugButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: context.editorColors.secondary
                    .withValues(alpha: 0.15 + 0.15 * _glowAnimation.value),
                blurRadius: 16 + 8 * _glowAnimation.value,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Depuração Passo a Passo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.editorColors.secondary,
              foregroundColor: context.editorColors.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Debug control button with scale-bounce; dimmed when disabled.
class _DebugControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  const _DebugControlButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return PressScale(
      onTap: onPressed,
      pressedScale: 0.82,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.35,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}
