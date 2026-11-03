import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:luminthor/core/router/app_router.dart';
import 'package:luminthor/features/editor/presentation/providers/editor_provider.dart';
import 'package:luminthor/features/home/presentation/providers/workspace_provider.dart';
import 'package:luminthor/features/learning/domain/learning_path.dart';
import 'package:luminthor/features/learning/presentation/providers/learning_provider.dart';
import 'package:luminthor/features/settings/presentation/providers/settings_provider.dart';
import 'package:luminthor/main.dart';

void main() {
  group('Learning progress', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('lumi-learning-');
      Hive.init(directory.path);
      await Hive.openBox('ide_box');
    });

    tearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });

    test(
        'Only correct, unlocked answers advance; XP survives restart without duplication',
        () async {
      var container = ProviderContainer();
      final first = LearningPath.lessons.first;
      final second = LearningPath.lessons[1];
      var notifier = container.read(learningProvider.notifier);
      expect(
          await notifier.submitAnswer(second, second.correctAnswer), isFalse);
      expect(await notifier.submitAnswer(first, (first.correctAnswer + 1) % 3),
          isFalse);
      expect(container.read(learningProvider).xp, 0);
      expect(await notifier.submitAnswer(first, first.correctAnswer), isTrue);
      expect(container.read(learningProvider).isUnlocked(second), isTrue);
      await Hive.box('ide_box').flush();
      container.dispose();
      await Hive.close();
      await Hive.openBox('ide_box');
      container = ProviderContainer();
      notifier = container.read(learningProvider.notifier);
      expect(container.read(learningProvider).nextLesson, second);
      expect(container.read(learningProvider).xp, first.xp);
      await notifier.submitAnswer(first, first.correctAnswer);
      expect(container.read(learningProvider).xp, first.xp);
      for (final lesson in LearningPath.lessons.skip(1)) {
        expect(
            await notifier.submitAnswer(lesson, lesson.correctAnswer), isTrue);
      }
      final progress = container.read(learningProvider);
      expect(progress.nextLesson, isNull);
      expect(progress.completedModules, 6);
      expect(progress.fraction, 1);
      expect(progress.xp, 1200);
      container.dispose();
    });

    test('Stored unknown IDs and gaps cannot unlock later lessons', () async {
      await Hive.box('ide_box').put(LearningNotifier.storageKey, [
        LearningPath.lessons.first.id,
        'obsolete-id',
        LearningPath.lessons[2].id
      ]);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final progress = container.read(learningProvider);
      expect(progress.completed, {LearningPath.lessons.first.id});
      expect(progress.nextLesson, LearningPath.lessons[1]);
      expect(progress.isUnlocked(LearningPath.lessons[2]), isFalse);
    });
  });

  Future<ProviderContainer> pumpLearning(WidgetTester tester,
      {Size size = const Size(390, 844),
      String route = '/learn',
      double textScale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    AppRouter.router.go(route);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MyApp(showSplash: false),
    ));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('Map and lesson remain usable with enlarged text',
      (tester) async {
    await pumpLearning(tester, size: const Size(320, 568), textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('continue-learning')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('check-answer')), 400,
        scrollable: find.byType(Scrollable).first, maxScrolls: 50);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(1440, 1100),
    const Size(960, 600),
    const Size(390, 844),
    const Size(320, 568)
  ]) {
    testWidgets('Map and lesson fit ${size.width.toInt()}px in both themes',
        (tester) async {
      final container = await pumpLearning(tester, size: size);
      expect(find.text('Trilha Lumi'), findsOneWidget);
      expect(find.text('0 XP'), findsOneWidget);
      expect(tester.takeException(), isNull);
      container.read(settingsProvider.notifier).toggleTheme();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('continue-learning')));
      await tester.pumpAndSettle();
      expect(find.text('Olá, Lumi!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('check-answer')), 400,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      container.read(settingsProvider.notifier).toggleTheme();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'Incorrect answers allow retry; completing and reviewing do not duplicate XP',
      (tester) async {
    final container =
        await pumpLearning(tester, route: '/learn/lesson/primeiro-programa');
    await tester.scrollUntilVisible(find.byKey(const ValueKey('answer-1')), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('answer-1')));
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('check-answer')), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('check-answer')));
    await tester.pumpAndSettle();
    expect(container.read(learningProvider).xp, 0);
    expect(find.textContaining('Ainda não.'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('answer-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('answer-0')));
    await tester.ensureVisible(find.byKey(const ValueKey('check-answer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('check-answer')));
    await tester.pumpAndSettle();
    expect(container.read(learningProvider).xp, 50);
    await tester.ensureVisible(find.byKey(const ValueKey('next-lesson')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('next-lesson')));
    await tester.pumpAndSettle();
    expect(find.text('Um passo de cada vez'), findsOneWidget);
    expect(find.textContaining('Isso mesmo!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Practice opens a separate file and preserves edits when revisited',
      (tester) async {
    final container =
        await pumpLearning(tester, route: '/learn/lesson/primeiro-programa');
    final original = container
        .read(workspaceProvider.notifier)
        .create(name: 'rascunho.lumi', source: 'print(42);');
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('practice-lesson')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-lesson')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(
        container.read(editorProvider).source, LearningPath.lessons.first.code);
    expect(container.read(workspaceProvider).documents, hasLength(2));
    await tester.enterText(find.byType(TextField), 'print("Meu exercício");');
    await tester.pump();
    await tester.tap(find.byTooltip('Voltar à aula'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('practice-lesson')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-lesson')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(editorProvider).source, 'print("Meu exercício");');
    expect(container.read(workspaceProvider).documents, hasLength(2));
    expect(
        container
            .read(workspaceProvider)
            .documents
            .firstWhere((doc) => doc.id == original.id)
            .source,
        'print(42);');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Locked and unknown lesson routes cannot bypass the roadmap',
      (tester) async {
    await pumpLearning(tester, route: '/learn/lesson/projeto-final');
    expect(find.text('Conclua a etapa anterior para abrir esta aula.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('practice-lesson')), findsNothing);
    AppRouter.router.go('/learn/lesson/does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('Esta aula não foi encontrada.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home provides an entry into the learning roadmap',
      (tester) async {
    await pumpLearning(tester, route: '/', size: const Size(1440, 1100));
    await tester.tap(find.byKey(const ValueKey('home-learning')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('continue-learning')), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar à Home'));
    await tester.pumpAndSettle();
    expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
  });
}
