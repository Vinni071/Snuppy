import 'package:flutter/foundation.dart';
import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/src/rust/interpreter.dart';

/// Editor view state: the source, the last compilation and the debug cursor.
@immutable
class CompilerState {
  final String source;
  final CompileResult? compileResult;
  final bool isLoading;
  final bool isDebugging;
  final int currentStepIndex;

  const CompilerState({
    required this.source,
    this.compileResult,
    required this.isLoading,
    required this.isDebugging,
    required this.currentStepIndex,
  });

  ExecutionStep? get currentStep {
    final trace = compileResult?.executionTrace;
    if (!isDebugging ||
        trace == null ||
        currentStepIndex < 0 ||
        currentStepIndex >= trace.length) {
      return null;
    }
    return trace[currentStepIndex];
  }

  String get visibleOutput {
    final result = compileResult;
    if (result == null) return '';
    if (!isDebugging) return result.output;
    if (currentStep == null) return '';
    return result.executionTrace
        .take(currentStepIndex + 1)
        .map((step) => step.output ?? '')
        .join();
  }

  /// Editable [source] with no compilation result and no debug session.
  const CompilerState.idle(this.source)
      : compileResult = null,
        isLoading = false,
        isDebugging = false,
        currentStepIndex = -1;

  CompilerState copyWith({
    String? source,
    CompileResult? Function()? compileResult,
    bool? isLoading,
    bool? isDebugging,
    int? currentStepIndex,
  }) {
    return CompilerState(
      source: source ?? this.source,
      compileResult:
          compileResult != null ? compileResult() : this.compileResult,
      isLoading: isLoading ?? this.isLoading,
      isDebugging: isDebugging ?? this.isDebugging,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}
