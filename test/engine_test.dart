import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/features/editor/presentation/screens/editor_screen.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/learning/domain/entities/learning_path.dart';
import 'package:luminthor/features/templates/domain/editor_templates.dart';
import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/src/rust/errors.dart';
import 'package:luminthor/src/rust/frb_generated.dart';
import 'package:luminthor/src/rust/interpreter/environment.dart';

void main() async {
  // Locate the compiled Rust library
  final dylibPath = Directory.current.path.endsWith('test')
      ? '../rust_core/target/debug/libide_engine.so'
      : 'rust_core/target/debug/libide_engine.so';

  setUpAll(() async {
    // Initialize RustLib with the local dylib
    await RustLib.init(
      externalLibrary: ExternalLibrary.open(dylibPath),
    );
  });

  test('Tokenize source code via Rust FFI', () async {
    final result = await tokenizeOnly(source: 'var x = 10;');
    final tokens = result.$1;
    final errors = result.$2;

    expect(errors, isEmpty);
    expect(tokens, hasLength(5));
    expect(tokens[0].tokenType, equals('Keyword(var)'));
    expect(tokens[1].lexeme, equals('x'));
    expect(tokens[2].tokenType, equals('Operator(=)'));
    expect(tokens[3].lexeme, equals('10'));
    expect(tokens[4].tokenType, equals('Delimiter(;)'));
  });

  test('Process source code and run interpreter via Rust FFI', () async {
    final result = await processSource(
      source: 'var x = 10; var y = 20; print(x + y);',
    );

    expect(result.success, isTrue);
    expect(result.errors, isEmpty);
    expect(result.output.trim(), equals('30'));
    expect(result.executionTrace, hasLength(3));

    final xVal = result.memoryState['x'];
    expect(xVal, isA<Value_Int>());
    expect((xVal as Value_Int).field0, equals(10));

    final yVal = result.memoryState['y'];
    expect(yVal, isA<Value_Int>());
    expect((yVal as Value_Int).field0, equals(20));
  });

  test('Home templates execute or produce their intended diagnostics',
      () async {
    for (var index = 0; index < EditorTemplates.templates.length; index++) {
      final template = EditorTemplates.templates[index];
      final result = await processSource(source: template.code);
      expect(result.success, index < 4, reason: template.title);
      if (index < 4) {
        expect(result.errors, isEmpty, reason: template.title);
        expect(result.output.trim(), isNotEmpty, reason: template.title);
      } else {
        expect(result.errors, isNotEmpty, reason: template.title);
      }
    }
  });

  test('Every learning example executes with the documented output', () async {
    for (final lesson in LearningPath.lessons) {
      final result = await processSource(source: lesson.code);
      expect(result.success, isTrue, reason: lesson.title);
      expect(result.errors, isEmpty, reason: lesson.title);
      expect(result.output.trim(), lesson.output, reason: lesson.title);
    }
  });

  test('FFI preserves accented diagnostic columns and end-of-source locations',
      () async {
    final lexical = await processSource(source: 'print("á"); @');
    final error = lexical.errors.whereType<CompileError_LexerError>().single;
    expect(error.message, contains('inválido'));
    expect(error.span?.line, 1);
    expect(error.span?.column, 13);
    expect(error.span?.start, 13);

    final syntax = await processSource(source: 'print("ação"');
    final missing = syntax.errors.whereType<CompileError_ParserError>().single;
    expect(missing.message, contains('fim do código'));
    expect(missing.span?.column, 13);
    expect(missing.span?.start, 14);
  });

  test('FFI keeps shadowed names grouped by scope', () async {
    final result = await processSource(
      source: 'var x = 1; { var x = 2; print(x); } print(x);',
    );
    expect(result.success, isTrue);
    final local =
        result.executionTrace.firstWhere((step) => step.output == '2\n');
    expect(local.scopes, hasLength(2));
    expect(local.scopes[0].depth, 0);
    expect(local.scopes[0].variables['x'], const Value.int(1));
    expect(local.scopes[1].depth, 1);
    expect(local.scopes[1].variables['x'], const Value.int(2));
    expect(result.executionTrace.first.variables['x'], const Value.int(1));
    expect(result.executionTrace.last.scopes, hasLength(1));
  });

  test('Console output follows the selected step, including repeated prints',
      () async {
    const source = 'print("eco"); var x = 1; print("eco"); x = 2; print(x);';
    final result = await processSource(source: source);
    expect(result.success, isTrue);
    final state = CompilerState(
      source: source,
      compileResult: result,
      isLoading: false,
      isDebugging: true,
      currentStepIndex: 0,
    );
    expect(state.visibleOutput, 'eco\n');
    expect(state.copyWith(currentStepIndex: 1).visibleOutput, 'eco\n');
    expect(state.copyWith(currentStepIndex: 2).visibleOutput, 'eco\neco\n');
    expect(state.copyWith(currentStepIndex: 4).visibleOutput, result.output);
    expect(state.copyWith(currentStepIndex: 0).visibleOutput, 'eco\n');
    expect(state.copyWith(isDebugging: false).visibleOutput, result.output);
  });

  testWidgets('Execute compiles valid Lumi and displays output in the editor',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(editorProvider.notifier);
    notifier.updateSource('var x = 10; print(x + 20);');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const EditorScreen(),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Execute'));
    // Native replies use the real event loop; provider updates use the widget
    // test's clock. Advance both until execution completes.
    for (var attempt = 0;
        attempt < 100 && container.read(editorProvider).compileResult == null;
        attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pump(const Duration(milliseconds: 350));
    expect(container.read(editorProvider).compileResult?.success, isTrue);
    expect(find.text('30\n'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
