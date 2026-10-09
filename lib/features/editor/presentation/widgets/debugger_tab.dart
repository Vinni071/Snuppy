import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:luminthor/src/rust/interpreter/environment.dart';
import '../providers/editor_provider.dart';

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
      return const Center(
        child: Text(
          'Execute o código primeiro para iniciar o depurador didático.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    final trace = result.executionTrace;

    if (trace.isEmpty) {
      return const Center(
        child: Text(
          'A execução não gerou passos (provavelmente ocorreu um erro).',
          style: TextStyle(color: Color(0xFF94A3B8)),
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
              child: const Icon(
                Icons.bug_report_outlined,
                size: 64,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Depurador Didático Visual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Explore a execução do seu programa passo a passo. Observe como as variáveis mudam na memória, como o escopo isola os dados e acompanhe a pilha de chamadas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8)),
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
    final step = trace[stepIndex];

    // Trigger step transition
    _triggerStepAnimation(stepIndex);

    return Column(
      children: [
        // ── Debugger Toolbar ──
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Passo ${stepIndex + 1} de ${trace.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      // Backward step
                      _DebugControlButton(
                        icon: Icons.arrow_back,
                        tooltip: 'Voltar um passo',
                        color: AppColors.secondary,
                        onPressed:
                            stepIndex > 0 ? notifier.stepBackward : null,
                      ),
                      // Forward step
                      _DebugControlButton(
                        icon: Icons.arrow_forward,
                        tooltip: 'Avançar um passo',
                        color: AppColors.secondary,
                        onPressed: stepIndex < trace.length - 1
                            ? notifier.stepForward
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Stop debugging
                      _DebugControlButton(
                        icon: Icons.close,
                        tooltip: 'Parar depuração',
                        color: AppColors.error,
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
                max: (trace.length - 1).toDouble(),
                divisions: trace.length > 1 ? trace.length - 1 : 1,
                activeColor: AppColors.secondary,
                onChanged: (val) => notifier.goToStep(val.toInt()),
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
              color: AppColors.surfaceLight.withOpacity(0.4),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.secondary.withOpacity(0.4)),
                        ),
                        child: Text(
                          step.action.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Linha ${step.line}, Coluna ${step.column}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: Colors.white,
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
                _buildVariableInspector(context, step.variables),
                const SizedBox(height: 16),

                // Call Stack
                _buildCallStackVisualizer(
                    context, step.callStack, step.scopeDepth),
                const SizedBox(height: 16),

                // Step Output Console
                _buildStepConsole(context, step.output),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariableInspector(
      BuildContext context, Map<String, Value> variables) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Estado da Memória (Variáveis)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (variables.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhuma variável declarada neste ponto.',
                  style: TextStyle(color: Color(0xFF6272A4), fontSize: 13),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2), // name
                  1: FlexColumnWidth(3), // value
                  2: FlexColumnWidth(1.5), // type
                },
                border: const TableBorder(
                  horizontalInside:
                      BorderSide(color: AppColors.border, width: 0.5),
                ),
                children: variables.entries.map((entry) {
                  final name = entry.key;
                  final val = entry.value;

                  // Get type and value representation
                  String typeName = '';
                  String displayVal = '';
                  Color valColor = Colors.white;

                  val.when(
                    int: (i) {
                      typeName = 'int';
                      displayVal = '$i';
                      valColor = AppColors.syntaxLiteralInt;
                    },
                    float: (f) {
                      typeName = 'float';
                      displayVal = '$f';
                      valColor = AppColors.syntaxLiteralInt;
                    },
                    string: (s) {
                      typeName = 'string';
                      displayVal = '"$s"';
                      valColor = AppColors.syntaxLiteralString;
                    },
                    bool: (b) {
                      typeName = 'bool';
                      displayVal = '$b';
                      valColor = AppColors.syntaxLiteralBool;
                    },
                    null_: () {
                      typeName = 'null';
                      displayVal = 'null';
                      valColor = AppColors.syntaxLiteralNull;
                    },
                    function: (name, params, bodyIndex) {
                      typeName = 'função';
                      displayVal = '$name(${params.join(", ")})';
                      valColor = AppColors.primaryLight;
                    },
                  );

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
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
                const Icon(Icons.layers,
                    color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pilha de Chamadas & Escopo',
                  style: Theme.of(context).textTheme.titleMedium,
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
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isTopFrame ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_right_alt,
                            color:
                                isTopFrame ? AppColors.primary : Colors.white30,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            frame == 'global'
                                ? '🌐 frame: <global>'
                                : '📞 frame: $frame',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: isTopFrame
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      if (isTopFrame)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
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
                const Icon(Icons.terminal, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Saída do Console (Acumulada)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              constraints:
                  const BoxConstraints(minHeight: 60, maxHeight: 150),
              child: SingleChildScrollView(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTheme.consoleTextStyle.copyWith(
                    color: (output == null || output.isEmpty)
                        ? const Color(0xFF6272A4)
                        : AppColors.success,
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
                color: AppColors.secondary
                    .withOpacity(0.15 + 0.15 * _glowAnimation.value),
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
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.background,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

/// Animated debug control buttons with scale-bounce
class _DebugControlButton extends StatefulWidget {
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
  State<_DebugControlButton> createState() => _DebugControlButtonState();
}

class _DebugControlButtonState extends State<_DebugControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _scaleController.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _scaleController.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => _scaleController.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.35,
          child: Tooltip(
            message: widget.tooltip,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.12),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
