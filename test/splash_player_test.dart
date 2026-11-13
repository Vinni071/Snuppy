import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/branding/brand_assets.dart';
import 'package:luminthor/features/splash/data/datasources/splash_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final asset in [
    BrandAssets.darkSplash,
    BrandAssets.lightSplash,
    BrandAssets.darkSplashPortrait,
    BrandAssets.lightSplashPortrait,
  ]) {
    testWidgets('AnimatedImageSplashPlayer plays $asset once and completes',
        (tester) async {
      await tester.runAsync(() async {
        final player = AnimatedImageSplashPlayer();
        final done = player.completed.first;
        await player.play(asset);
        await player.firstFrame;
        expect(await done.timeout(const Duration(seconds: 30)), isTrue);
        await player.dispose();
      });
    });
  }
}
