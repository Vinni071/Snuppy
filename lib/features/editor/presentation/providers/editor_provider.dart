import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/features/editor/domain/compiler_state.dart';
import '../../../home/domain/workspace_document.dart';
import '../../../home/presentation/providers/workspace_provider.dart';
import '../../../../src/rust/errors.dart';

final sourceCompilerProvider = Provider<Future<CompileResult> Function(String)>(
  (ref) => (source) => processSource(source: source),
);

class EditorNotifier extends Notifier<CompilerState> {
  int _sourceRevision = 0;

  @override
  CompilerState build() {
    // Load saved source on build
    String initialSource = '// Welcome to Mobile IDE\n'
        'fn fibonacci(n) {\n'
        '  if n <= 1 {\n'
        '    return n;\n'
        '  }\n'
        '  return fibonacci(n - 1) + fibonacci(n - 2);\n'
        '}\n'
        '\n'
        'print(fibonacci(10));\n';
    initialSource =
        ref.read(workspaceProvider).activeDocument?.source ?? initialSource;

    return CompilerState(
      source: initialSource,
      compileResult: null,
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
  }

  void updateSource(String newSource) {
    if (newSource == state.source) return;
    _sourceRevision++;
    state = state.copyWith(
      source: newSource,
      compileResult: () => null,
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
    ref.read(workspaceProvider.notifier).updateSource(newSource);
  }

  void openDocument(WorkspaceDocument document) {
    _sourceRevision++;
    ref.read(workspaceProvider.notifier).open(document);
    state = CompilerState(
      source: document.source,
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
  }

  Future<void> runCompilation() async {
    final revision = _sourceRevision;
    state = state.copyWith(
      isLoading: true,
      isDebugging: false,
      currentStepIndex: -1,
      compileResult: () => null,
    );
    try {
      final result = await ref.read(sourceCompilerProvider)(state.source);
      if (revision != _sourceRevision) return;
      state = state.copyWith(
        compileResult: () => result,
        isLoading: false,
      );
    } catch (error, stack) {
      if (revision != _sourceRevision) return;
      debugPrint('Falha na comunicação com a engine Lumi: $error\n$stack');
      state = state.copyWith(
        isLoading: false,
        compileResult: () => const CompileResult(
          tokens: [],
          output: '',
          errors: [
            CompileError.runtimeError(
              message:
                  'Não foi possível executar o programa porque a comunicação '
                  'com a engine Lumi falhou. Feche e abra o aplicativo novamente. '
                  'Se o problema continuar, recompile o aplicativo para atualizar '
                  'a biblioteca Rust.',
              callStack: [],
            ),
          ],
          memoryState: {},
          executionTrace: [],
          warnings: [],
          success: false,
        ),
      );
    }
  }

  void startDebugging() {
    final result = state.compileResult;
    if (result == null || result.executionTrace.isEmpty) return;
    state = state.copyWith(
      isDebugging: true,
      currentStepIndex: 0,
    );
  }

  void stopDebugging() {
    state = state.copyWith(
      isDebugging: false,
      currentStepIndex: -1,
    );
  }

  void stepForward() {
    final result = state.compileResult;
    if (result == null || !state.isDebugging) return;
    if (state.currentStepIndex < result.executionTrace.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  void stepBackward() {
    if (!state.isDebugging) return;
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  void goToStep(int index) {
    final result = state.compileResult;
    if (result == null || !state.isDebugging) return;
    if (index >= 0 && index < result.executionTrace.length) {
      state = state.copyWith(currentStepIndex: index);
    }
  }
}

final editorProvider =
    NotifierProvider<EditorNotifier, CompilerState>(EditorNotifier.new);
