import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ide/main.dart';
import 'package:ide/src/rust/frb_generated.dart';

void main() {
  final dylibPath = Directory.current.path.endsWith('test')
      ? '../rust_core/target/debug/libide_engine.so'
      : 'rust_core/target/debug/libide_engine.so';

  setUpAll(() async {
    // Initialize RustLib with local dylib for tests
    await RustLib.init(
      externalLibrary: ExternalLibrary.open(dylibPath),
    );
  });

  testWidgets('Snuppy App renders editor successfully',
      (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Allow any async initialization or frame layout to settle
    await tester.pumpAndSettle();

    // Verify that the title logo is displayed.
    expect(find.text('Snuppy'), findsOneWidget);
  });
}
