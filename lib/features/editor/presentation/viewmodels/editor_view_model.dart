import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/features/editor/data/rust_source_compiler.dart';
import 'package:luminthor/features/editor/domain/source_compiler.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/compiler_state.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

export 'package:luminthor/features/editor/data/rust_source_compiler.dart';
export 'package:luminthor/features/editor/presentation/viewmodels/compiler_state.dart';

/// Editing, compilation and step-by-step debugging of the active document.
class EditorNotifier extends Notifier<CompilerState> {
  static const _fallbackSource = '// Welcome to Mobile IDE\n'
      'fn fibonacci(n) {\n'
      '  if n <= 1 {\n'
      '    return n;\n'
      '  }\n'
      '  return fibonacci(n - 1) + fibonacci(n - 2);\n'
      '}\n'
      '\n'
      'print(fibonacci(10));\n';

  /// Incremented on every source change so results of a compilation that
  /// finished after the code was edited are discarded.
  int _sourceRevision = 0;

  @override
  CompilerState build() {
    final source =
        ref.read(workspaceProvider).activeDocument?.source ?? _fallbackSource;
    return CompilerState.idle(source);
  }

  void updateSource(String newSource) {
    if (newSource == state.source) return;
    _sourceRevision++;
    state = CompilerState.idle(newSource);
    ref.read(workspaceProvider.notifier).updateSource(newSource);
  }

  void openDocument(WorkspaceDocument document) {
    ref.read(workspaceProvider.notifier).open(document);
    _show(document);
  }

  /// Creates a document in the workspace and opens it in the editor.
  WorkspaceDocument createDocument({
    required String name,
    String source = '',
    String origin = DocumentOrigin.created,
  }) {
    final document = ref
        .read(workspaceProvider.notifier)
        .create(name: name, source: source, origin: origin);
    _show(document);
    return document;
  }

  /// Reopens the document created from [origin] (keeping the learner's
  /// edits), or creates it from [source] the first time.
  WorkspaceDocument openOrCreateDocument({
    required String name,
    required String source,
    required String origin,
  }) {
    final existing = ref.read(workspaceProvider).findByOrigin(origin);
    if (existing != null) {
      openDocument(existing);
      return existing;
    }
    return createDocument(name: name, source: source, origin: origin);
  }

  void _show(WorkspaceDocument document) {
    _sourceRevision++;
    state = CompilerState.idle(document.source);
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
      state = state.copyWith(compileResult: () => result, isLoading: false);
    } catch (error, stack) {
      if (revision != _sourceRevision) return;
      reportError('Falha na comunicação com a engine Lumi', error, stack);
      state = state.copyWith(
        isLoading: false,
        compileResult: engineUnavailableResult,
      );
    }
  }

  void startDebugging() {
    final result = state.compileResult;
    if (result == null || result.executionTrace.isEmpty) return;
    state = state.copyWith(isDebugging: true, currentStepIndex: 0);
  }

  void stopDebugging() {
    state = state.copyWith(isDebugging: false, currentStepIndex: -1);
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
