import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:ide/src/rust/frb_generated.dart';
import 'package:ide/src/rust/api.dart';
import 'package:ide/src/rust/interpreter/environment.dart';

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
}
