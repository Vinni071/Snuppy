import '../../../src/rust/api.dart';

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

  factory CompilerState.initial() {
    return const CompilerState(
      source: '// Write your Lumi code here...\nprint("Hello, Luminthor!");\n',
      compileResult: null,
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
  }

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
