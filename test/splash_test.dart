import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/app.dart';
import 'package:luminthor/app/router/app_router.dart';
import 'package:luminthor/core/branding/brand_assets.dart';
import 'package:luminthor/core/branding/luminthor_logo.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luminthor/features/splash/data/datasources/splash_player.dart';

class FakeSplashPlayer implements SplashPlayer {
  final completion = StreamController<bool>.broadcast(sync: true);
  final failures = StreamController<String>.broadcast(sync: true);
  String? asset;
  bool disposed = false;

  @override
  Stream<bool> get completed => completion.stream;
  @override
  Stream<String> get errors => failures.stream;
  @override
  Future<void> get firstFrame async {}
  @override
  Future<void> play(String asset) async => this.asset = asset;
  @override
  Widget buildVideo(Color background) =>
      ColoredBox(color: background, key: const ValueKey('fake-splash-video'));
  @override
  Future<void> dispose() async {
    disposed = true;
    await completion.close();
    await failures.close();
  }
}

Future<ProviderContainer> pumpSplash(
    WidgetTester tester, FakeSplashPlayer player,
    {bool light = false, Future<String?>? initialization}) async {
  final container = ProviderContainer(overrides: [
    splashPlayerFactoryProvider.overrideWithValue(() => player),
  ]);
  addTearDown(container.dispose);
  if (light) container.read(settingsProvider.notifier).toggleTheme();
  AppRouter.router.go('/');
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MyApp(initialization: initialization),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  return container;
}

void main() {
  for (final light in [false, true]) {
    testWidgets(
        'Splash selects ${light ? 'light' : 'dark'} video and opens Home on completion',
        (tester) async {
      final player = FakeSplashPlayer();
      await pumpSplash(tester, player, light: light);
      expect(player.asset,
          light ? BrandAssets.lightSplash : BrandAssets.darkSplash);
      expect(find.byKey(const ValueKey('luminthor-splash')), findsOneWidget);
      player.completion.add(true);
      await tester.pumpAndSettle();
      expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
      expect(player.disposed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Skip waits for engine initialization before showing Home',
      (tester) async {
    final player = FakeSplashPlayer();
    final initialization = Completer<String?>();
    await pumpSplash(tester, player, initialization: initialization.future);
    await tester.tap(find.byKey(const ValueKey('skip-splash')));
    await tester.pump();
    expect(find.text('Preparando seu espaço...'), findsOneWidget);
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsNothing);
    expect(player.disposed, isTrue);
    initialization.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Video errors use the vector logo and still open Home',
      (tester) async {
    final player = FakeSplashPlayer();
    await pumpSplash(tester, player);
    player.failures.add('Decoder unavailable');
    await tester.pump();
    final logo = tester.widget<LuminthorLogo>(find.byType(LuminthorLogo));
    expect(logo.isDark, isTrue);
    expect(logo.part, LogoPart.full);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
    expect(player.disposed, isTrue);
  });

  testWidgets('A stalled video cannot trap startup indefinitely',
      (tester) async {
    final player = FakeSplashPlayer();
    await pumpSplash(tester, player);
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
    expect(player.disposed, isTrue);
  });

  testWidgets('Engine failures remain visible after the splash',
      (tester) async {
    final player = FakeSplashPlayer();
    await pumpSplash(tester, player,
        initialization: Future.value('Falha na engine de teste'));
    player.completion.add(true);
    await tester.pumpAndSettle();
    expect(find.text('Falha na engine de teste'), findsOneWidget);
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
