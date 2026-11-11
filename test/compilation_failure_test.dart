import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/editor/presentation/widgets/console_panel.dart';
import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/src/rust/errors.dart';

const successfulResult = CompileResult(
  tokens: [],
  output: '42\n',
  errors: [],
  memoryState: {},
  executionTrace: [],
  warnings: [],
  success: true,
);

void main() {
  testWidgets('Engine failures appear in diagnostics and a later run recovers',
      (tester) async {
    var shouldFail = true;
    final container = ProviderContainer(overrides: [
      sourceCompilerProvider.overrideWithValue((source) async {
        if (shouldFail) throw StateError('Incompatible native library');
        return successfulResult;
      }),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: ConsolePanel()),
      ),
    ));
    final notifier = container.read(editorProvider.notifier);
    notifier.updateSource('print(42);');
    await notifier.runCompilation();
    await tester.pump(const Duration(milliseconds: 350));
    final state = container.read(editorProvider);
    expect(state.isLoading, isFalse);
    expect(state.compileResult?.success, isFalse);
    expect(
        state.compileResult?.errors.single, isA<CompileError_RuntimeError>());
    expect(find.textContaining('a comunicação com a engine Lumi falhou'),
        findsOneWidget);

    shouldFail = false;
    await notifier.runCompilation();
    await tester.pump(const Duration(milliseconds: 350));
    expect(container.read(editorProvider).compileResult?.success, isTrue);
    expect(find.text('42\n'), findsOneWidget);
    expect(find.textContaining('a comunicação com a engine Lumi falhou'),
        findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('An old failed execution does not overwrite an edited program',
      () async {
    final pending = Completer<CompileResult>();
    final container = ProviderContainer(overrides: [
      sourceCompilerProvider.overrideWithValue((source) => pending.future),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(editorProvider.notifier);
    notifier.updateSource('print(1);');
    final run = notifier.runCompilation();
    notifier.updateSource('print(2);');
    pending.completeError(StateError('Old library failed'));
    await run;
    final state = container.read(editorProvider);
    expect(state.source, 'print(2);');
    expect(state.compileResult, isNull);
    expect(state.isLoading, isFalse);
  });
}
