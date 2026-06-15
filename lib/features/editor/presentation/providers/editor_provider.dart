import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:ide/src/rust/api.dart';
import 'package:ide/features/editor/domain/compiler_state.dart';

class EditorNotifier extends Notifier<CompilerState> {
  @override
  CompilerState build() {
    // Load saved source on build
    String initialSource =
        '// Write your Lumi code here...\nprint("Hello, Snuppy!");\n';
    try {
      final box = Hive.box('ide_box');
      final saved = box.get('source_code');
      if (saved != null && saved is String && saved.isNotEmpty) {
        initialSource = saved;
      }
    } catch (_) {}

    return CompilerState(
      source: initialSource,
      compileResult: null,
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
  }

  void updateSource(String newSource) {
    state = state.copyWith(source: newSource);
    try {
      final box = Hive.box('ide_box');
      box.put('source_code', newSource);
    } catch (_) {}
  }

  Future<void> runCompilation() async {
    state = state.copyWith(
        isLoading: true, isDebugging: false, currentStepIndex: -1);
    try {
      final result = await processSource(source: state.source);
      state = state.copyWith(
        compileResult: () => result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        compileResult: () => null,
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
