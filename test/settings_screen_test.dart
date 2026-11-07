import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/router/app_router.dart';
import 'package:luminthor/features/home/presentation/widgets/home_components.dart';
import 'package:luminthor/features/settings/presentation/providers/settings_provider.dart';
import 'package:luminthor/main.dart';

void main() {
  Future<ProviderContainer> pumpSettings(WidgetTester tester,
      {Size size = const Size(390, 844), double textScale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    AppRouter.router.go('/settings');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MyApp(showSplash: false),
    ));
    await tester.pumpAndSettle();
    return container;
  }

  for (final size in const [Size(1440, 900), Size(390, 844), Size(320, 568)]) {
    testWidgets('Settings fit ${size.width.toInt()}px in both themes',
        (tester) async {
      final container = await pumpSettings(tester, size: size);
      expect(tester.takeException(), isNull);
      container.read(settingsProvider.notifier).toggleTheme();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Settings stay usable with enlarged text', (tester) async {
    await pumpSettings(tester, size: const Size(320, 568), textScale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings use the same surfaces as the Home', (tester) async {
    await pumpSettings(tester);
    final context = tester.element(find.text('Aparência'));
    final palette =
        HomePalette(Theme.of(context).brightness == Brightness.dark);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, palette.background);
    expect(find.byType(HomeCard), findsNWidgets(2));
  });

  testWidgets('Switch and slider still change the settings', (tester) async {
    final container = await pumpSettings(tester);
    final initialMode = container.read(settingsProvider).themeMode;
    await tester.tap(find.byKey(const ValueKey('settings-dark-theme')));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).themeMode, isNot(initialMode));

    final initialSize = container.read(settingsProvider).fontSize;
    await tester.drag(
        find.byKey(const ValueKey('settings-font-size')), const Offset(80, 0));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).fontSize, isNot(initialSize));
    expect(find.text('${container.read(settingsProvider).fontSize.toInt()} px'),
        findsWidgets);
  });

  testWidgets('Back returns to Home', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
  });
}
