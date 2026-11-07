import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/features/home/presentation/widgets/home_components.dart';
import 'package:luminthor/features/home/presentation/widgets/home_dock.dart';

const _items = [
  HomeDockItem(label: 'Home', glyph: HomeDockGlyph.home),
  HomeDockItem(label: 'Arquivos', glyph: HomeDockGlyph.folder),
  HomeDockItem(label: 'Templates', glyph: HomeDockGlyph.grid),
  HomeDockItem(label: 'Aprender', glyph: HomeDockGlyph.route),
];

Widget _dock(int selected,
    {ValueChanged<int>? onSelected, bool still = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: still),
      child: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: HomeDock(
            palette: const HomePalette(false),
            items: _items,
            selectedIndex: selected,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

Finder _active(int index) => find.byKey(ValueKey('home-dock-active-$index'));
Finder _idle(int index) => find.byKey(ValueKey('home-dock-idle-$index'));

double _slotWidth(WidgetTester tester, int index) =>
    tester.getSize(find.byKey(ValueKey('home-dock-$index'))).width;

void main() {
  testWidgets('Every label stays visible; only selection colors the icon',
      (tester) async {
    await tester.pumpWidget(_dock(0));
    for (final item in _items) {
      expect(find.text(item.label), findsOneWidget);
    }
    expect(_active(0), findsOneWidget);
    expect(_idle(0), findsNothing);
    expect(_idle(1), findsOneWidget);
    expect(_active(1), findsNothing);
    expect(_slotWidth(tester, 0), greaterThan(_slotWidth(tester, 2)));
  });

  testWidgets('A fixed insert sits between items and never slides',
      (tester) async {
    Widget dock(int selected) => MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: HomeDock(
                palette: const HomePalette(false),
                items: _items,
                selectedIndex: selected,
                onSelected: (_) {},
                insertAt: 2,
                insertWidth: 72,
                insert: const SizedBox(key: ValueKey('insert')),
              ),
            ),
          ),
        );
    await tester.pumpWidget(dock(0));
    final insert = find.byKey(const ValueKey('insert'));
    expect(tester.getSize(insert).width, 72);
    expect(
        tester.getTopLeft(insert).dx,
        greaterThan(
            tester.getTopRight(find.byKey(const ValueKey('home-dock-1'))).dx -
                1));
    await tester.pumpWidget(dock(3));
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.getSize(insert).width, 72);
    await tester.pumpAndSettle();
    expect(_active(3), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tapping an idle item reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(_dock(0, onSelected: (index) => tapped = index));
    await tester.tap(find.byKey(const ValueKey('home-dock-2')));
    expect(tapped, 2);
  });

  testWidgets('Selecting springs past the target and settles on it',
      (tester) async {
    await tester.pumpWidget(_dock(0));
    final selectedWidth = _slotWidth(tester, 0);
    double total() => [for (var s = 0; s < 4; s++) _slotWidth(tester, s)]
        .reduce((a, b) => a + b);
    final barWidth = total();
    await tester.pumpWidget(_dock(2));
    expect(_slotWidth(tester, 0), selectedWidth);

    var widest = 0.0;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      final width = _slotWidth(tester, 2);
      if (width > widest) widest = width;
      expect(total(), moreOrLessEquals(barWidth));
    }
    await tester.pumpAndSettle();

    expect(widest, greaterThan(selectedWidth));
    expect(_slotWidth(tester, 2), moreOrLessEquals(selectedWidth));
    expect(_active(2), findsOneWidget);
    expect(_active(0), findsNothing);
  });

  testWidgets('A tap during the motion continues from the current position',
      (tester) async {
    await tester.pumpWidget(_dock(0));
    await tester.pumpWidget(_dock(1));
    await tester.pump(const Duration(milliseconds: 60));
    final before = _slotWidth(tester, 1);
    await tester.pumpWidget(_dock(3));
    expect(_slotWidth(tester, 1), moreOrLessEquals(before));
    await tester.pumpAndSettle();
    expect(_active(3), findsOneWidget);
    expect(_active(1), findsNothing);
  });

  testWidgets('Reduced motion jumps straight to the selected item',
      (tester) async {
    await tester.pumpWidget(_dock(0, still: true));
    await tester.pumpWidget(_dock(2, still: true));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(_active(2), findsOneWidget);
    expect(_active(0), findsNothing);
  });

  testWidgets('Items expose their label and selection to assistive tech',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_dock(1));
    expect(
        tester.getSemantics(find.byKey(const ValueKey('home-dock-0'))),
        matchesSemantics(
            label: 'Home',
            isButton: true,
            hasSelectedState: true,
            isSelected: false,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true));
    semantics.dispose();
  });
}
