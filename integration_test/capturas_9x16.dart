import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luminthor/main.dart' as app;
import 'package:luminthor/shared/widgets/press_scale.dart';

/// Gera capturas de todas as telas em proporção 9x16 (1080x1920, layout mobile).
///
/// As imagens vão para output/capturas-9x16 (ou CAPTURAS_DIR) e não tocam nas
/// figuras do TCC. Rode com um diretório de dados isolado:
/// XDG_DATA_HOME=/tmp/luminthor-capturas flutter test integration_test/capturas_9x16.dart -d linux
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capturas do Luminthor em 9x16', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await app.main();
    await _until(tester, () => find.byKey(const ValueKey('skip-splash')).evaluate().isNotEmpty || _homeVisible());
    if (find.byKey(const ValueKey('skip-splash')).evaluate().isNotEmpty) {
      await _frames(tester, 30);
      await _shot(tester, '00-splash');
    }
    if (find.byKey(const ValueKey('skip-splash')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const ValueKey('skip-splash')));
      await tester.pump();
    }
    await _until(tester, _homeVisible, seconds: 40);
    await _frames(tester, 12);
    await _shot(tester, '01-home-vazia');

    await _newFile(tester, 'ola', 'print("Olá, Lumi!");');
    await tester.tap(find.byTooltip('Voltar à Home'));
    await _until(tester, _homeVisible);
    await _frames(tester, 10);

    await _newFile(tester, 'variaveis', 'var pontos = 8;\nvar total = 15;\nprint(total);');
    await tester.tap(find.byTooltip('Voltar à Home'));
    await _until(tester, _homeVisible);
    await _frames(tester, 10);
    // A ListView da home é preguiçosa: a seção só existe depois de rolar até ela.
    final recentes = find.text('Arquivos recentes');
    await tester.scrollUntilVisible(recentes, 150,
        scrollable: find
            .descendant(
                of: find.byKey(const ValueKey('home-section-0')),
                matching: find.byType(Scrollable))
            .first);
    await _frames(tester, 4);
    // Duração zero: salta direto, e o pump seguinte desenha a nova posição.
    Scrollable.ensureVisible(tester.element(recentes.last), alignment: 0.1);
    await _frames(tester, 10);
    await _shot(tester, 'captura-home');

    await tester.drag(
        find.byKey(const ValueKey('home-section-0')), const Offset(0, 600));
    await _frames(tester, 6);
    await _shot(tester, 'captura-home-topo');

    final settings = find.byTooltip('Configurações');
    if (settings.evaluate().isNotEmpty) {
      await tester.tap(settings.first);
      await _frames(tester, 16);
      await _shot(tester, 'captura-configuracoes');
      await tester.binding.handlePopRoute();
      await _until(tester, _homeVisible);
      await _frames(tester, 10);
    }

    if (find.text('Trilha Lumi').evaluate().isNotEmpty) {
      await tester.tap(find.text('Trilha Lumi'));
    } else {
      await tester.tap(find.text('Aprender'));
    }
    await _until(tester, () => find.text('Olá, Lumi!').evaluate().isNotEmpty);
    await _frames(tester, 12);
    await _shot(tester, 'captura-trilha');

    await tester.tap(find.text('Olá, Lumi!'));
    await _until(tester, () => find.text('Veja em Lumi').evaluate().isNotEmpty);
    await _frames(tester, 8);
    await tester.drag(
        find.byKey(const ValueKey('lesson-content-primeiro-programa')),
        const Offset(0, -120));
    await _frames(tester, 6);
    await _shot(tester, 'captura-aula');

    await _openEditor(tester, 'comparativo', 'var total = 15;\nprint(totla);');
    await _execute(tester);
    await _until(tester, () => find.textContaining('não foi declarada').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await _shot(tester, 'diagnostico-lumi-totla');

    await _replaceAndRun(tester, 'print(1);\n@');
    await _until(tester, () => find.textContaining('inválido').evaluate().isNotEmpty || find.textContaining('invalido').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await _shot(tester, 'captura-lexico');

    await _replaceAndRun(tester, 'print(1;');
    await _until(tester, () => find.text('Erro de Sintaxe').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await _shot(tester, 'captura-sintatico');

    await _replaceAndRun(tester, 'var pontos = 8;\nprint(pntos);');
    await _until(tester, () => find.textContaining('Dica:').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await _shot(tester, 'captura-semantico');

    await _replaceAndRun(tester, 'var divisor = 0;\nprint(1 / divisor);');
    await _until(tester, () => find.text('Erro de Execução').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await _shot(tester, 'captura-execucao');

    await _replaceAndRun(tester, 'var x = 0;\nx = 3 + 5 * 2;');
    await _until(tester, () => find.textContaining('Nenhuma saída').evaluate().isNotEmpty || find.textContaining('13').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await tester.tap(find.text('Tokens'));
    await _frames(tester, 14);
    await tester.drag(find.text('Literal(integer)').first, const Offset(0, -300));
    await _frames(tester, 6);
    await _shot(tester, 'captura-tokens');

    await tester.tap(find.text('AST'));
    await _frames(tester, 14);
    await _shot(tester, 'captura-ast');

    await tester.tap(find.text('Editor'));
    await _frames(tester, 6);
    await _replaceAndRun(
      tester,
      'fn dobro(numero) {\n  return numero * 2;\n}\nprint(dobro(6));',
    );
    await _until(tester, () => find.textContaining('12').evaluate().isNotEmpty);
    await _dismissStatus(tester);
    await tester.tap(find.text('Trace'));
    await _frames(tester, 8);
    await tester.tap(find.text('Iniciar Depuração Passo a Passo'));
    await _frames(tester, 8);
    for (var step = 0; step < 12; step++) {
      if (find.text('CHAMADA DE FUNÇÃO').evaluate().isNotEmpty) break;
      final forward = find.byTooltip('Avançar um passo');
      if (forward.evaluate().isEmpty) break;
      await tester.tap(forward);
      await _frames(tester, 4);
    }
    await tester.drag(find.text('Escopo global'), const Offset(0, -150));
    await _frames(tester, 4);
    await _shot(tester, 'captura-depurador');

    await tester.tap(find.byTooltip('Parar depuração'));
    await _frames(tester, 6);
    await tester.tap(find.text('Editor'));
    await _frames(tester, 6);
    final field = find.byType(TextField);
    await tester.enterText(field, 'var pontos = 8;\n');
    await _frames(tester, 4);
    await tester.enterText(field, 'var pontos = 8;\nvar total = 15;\np');
    await _frames(tester, 8);
    await _shot(tester, 'captura-autocompletar');

    await _shotKeyboard(tester);
  }, timeout: const Timeout(Duration(minutes: 6)));
}

bool _homeVisible() =>
    find.textContaining('Seu próximo código').evaluate().isNotEmpty ||
    find.text('Novo arquivo').evaluate().isNotEmpty;

Future<void> _frames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _until(
  WidgetTester tester,
  bool Function() ready, {
  int seconds = 20,
}) async {
  final deadline = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 80));
    if (ready()) return;
  }
  final texts = find.byType(Text).evaluate().map((element) {
    final widget = element.widget;
    return widget is Text ? widget.data ?? widget.textSpan?.toPlainText() : null;
  }).whereType<String>().take(40).join(' | ');
  fail('Tempo esgotado. Textos visíveis: $texts');
}

Future<void> _newFile(WidgetTester tester, String name, String source) async {
  final hero = find.byKey(const ValueKey('hero-new-file'));
  if (hero.evaluate().isNotEmpty) {
    await tester.tap(hero);
  } else {
    await tester.tap(find.text('Novo arquivo').first);
  }
  await _until(tester, () => find.text('Criar arquivo').evaluate().isNotEmpty);
  await tester.enterText(
    find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(TextField)),
    name,
  );
  await tester.tap(find.text('Criar arquivo'));
  await _until(tester, () => find.byTooltip('Voltar à Home').evaluate().isNotEmpty);
  await _frames(tester, 8);
  await tester.enterText(find.byType(TextField), source);
  await _frames(tester, 4);
}

Future<void> _openEditor(WidgetTester tester, String name, String source) async {
  await tester.tap(find.byTooltip('Voltar à trilha'));
  await _until(tester, () => find.text('Olá, Lumi!').evaluate().isNotEmpty || _homeVisible());
  if (!_homeVisible()) {
    if (find.text('Home').evaluate().isNotEmpty) {
      await tester.tap(find.text('Home').first);
    } else {
      await tester.tap(find.byIcon(Icons.home_outlined).first);
    }
    await _until(tester, _homeVisible);
  }
  await _frames(tester, 6);
  await _newFile(tester, name, source);
}

Future<void> _execute(WidgetTester tester) async {
  final element = tester.element(find.text('Execute'));
  var invoked = false;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is PressScale) {
      widget.onTap?.call();
      invoked = true;
      return false;
    }
    return true;
  });
  expect(invoked, isTrue, reason: 'botão Execute');
  await _frames(tester, 6);
}

Future<void> _dismissStatus(WidgetTester tester) async {
  await _frames(tester, 46);
}

Future<void> _replaceAndRun(WidgetTester tester, String source) async {
  if (find.text('Editor').evaluate().isNotEmpty &&
      find.byType(TextField).evaluate().isEmpty) {
    await tester.tap(find.text('Editor'));
    await _frames(tester, 6);
  }
  final finder = find.byType(TextField);
  await tester.enterText(finder, source);
  await _frames(tester, 2);
  final widget = tester.widget<TextField>(finder);
  if (widget.controller?.text != source) {
    widget.controller!.value = TextEditingValue(
      text: source,
      selection: TextSelection.collapsed(offset: source.length),
    );
    widget.onChanged?.call(source);
  }
  await _frames(tester, 6);
  await _execute(tester);
}

Future<void> _shotKeyboard(WidgetTester tester) async {
  final view = tester.view;
  final log = File('/tmp/luminthor-teclado.txt');
  try {
    view.viewInsets = FakeViewPadding(bottom: 280 * view.devicePixelRatio);
    await _frames(tester, 8);
    await log.writeAsString(
        'insets=${view.viewInsets.bottom} toolbar=${find.byTooltip('Recolher teclado').evaluate().length}\n');
    if (find.byTooltip('Recolher teclado').evaluate().isNotEmpty) {
      await _shot(tester, 'captura-editor');
    }
  } catch (error) {
    await log.writeAsString('erro: $error\n');
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  // CAPTURAS_SO=captura-ast,captura-home regrava apenas as capturas listadas.
  final only = Platform.environment['CAPTURAS_SO'];
  if (only != null && only.isNotEmpty && !only.split(',').contains(name)) {
    return;
  }
  await tester.pump();
  final bytes = await tester.runAsync(() async {
    final renderView = tester.binding.renderViews.first;
    final layer = renderView.debugLayer;
    final ui.Image image;
    if (layer is OffsetLayer) {
      image = await layer.toImage(renderView.paintBounds);
    } else {
      RenderRepaintBoundary? best;
      var bestArea = 0.0;
      for (final object in tester.allRenderObjects) {
        if (object is RenderRepaintBoundary && object.size.isFinite) {
          final area = object.size.width * object.size.height;
          if (area > bestArea) {
            best = object;
            bestArea = area;
          }
        }
      }
      if (best == null) throw StateError('Nenhuma área de pintura encontrada');
      image = await best.toImage(pixelRatio: tester.view.devicePixelRatio);
    }
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  final dir = Platform.environment['CAPTURAS_DIR'] ?? 'output/capturas-9x16';
  final file = File('$dir/$name.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!, flush: true);
}
