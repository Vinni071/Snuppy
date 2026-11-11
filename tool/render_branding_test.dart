// Run with: flutter test tool/render_branding_test.dart
// Renders the supplied logo into launcher assets and captures Home previews.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/app.dart';
import 'package:luminthor/app/router/app_router.dart';
import 'package:luminthor/core/branding/brand_assets.dart';
import 'package:luminthor/core/branding/luminthor_logo.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';

Future<void> saveRender(WidgetTester tester, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('branding-render')));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(path).parent.create(recursive: true);
    await File(path).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    var directory = File(Platform.resolvedExecutable).parent;
    while (directory.path != directory.parent.path) {
      final fonts =
          Directory('${directory.path}/bin/cache/artifacts/material_fonts');
      if (fonts.existsSync()) {
        for (final entry in {
          'Roboto': 'Roboto-Regular.ttf',
          'MaterialIcons': 'MaterialIcons-Regular.otf',
          'monospace': 'Roboto-Regular.ttf'
        }.entries) {
          final loader = FontLoader(entry.key);
          loader.addFont(Future.value(ByteData.sublistView(
              File('${fonts.path}/${entry.value}').readAsBytesSync())));
          await loader.load();
        }
        break;
      }
      directory = directory.parent;
    }
  });

  for (final dark in [true, false]) {
    testWidgets('Render ${dark ? 'dark' : 'light'} launcher logo',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final background = dark ? const Color(0xFF080808) : Colors.white;
      await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: const ValueKey('branding-render'),
            child: ColoredBox(
                color: background,
                child: Center(
                    child: LuminthorLogo(
                        isDark: dark, width: 720, part: LogoPart.symbol))),
          )));
      await tester.runAsync(() async {
        final picture = await vg.loadPicture(
            SvgAssetLoader(dark ? BrandAssets.darkLogo : BrandAssets.lightLogo),
            null);
        picture.picture.dispose();
      });
      await tester.pumpAndSettle();
      await saveRender(
          tester, 'assets/branding/app_icon_${dark ? 'dark' : 'light'}.png');
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    for (final dark in [true, false]) {
      testWidgets('Preview Home ${size.width} ${dark ? 'dark' : 'light'}',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer();
        addTearDown(container.dispose);
        if (!dark) container.read(settingsProvider.notifier).toggleTheme();
        AppRouter.router.go('/');
        await tester.pumpWidget(UncontrolledProviderScope(
            container: container,
            child: const RepaintBoundary(
                key: ValueKey('branding-render'),
                child: MyApp(showSplash: false))));
        await tester.pumpAndSettle();
        await saveRender(tester,
            'build/branding-preview/home-${size.width.toInt()}-${dark ? 'dark' : 'light'}.png');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
