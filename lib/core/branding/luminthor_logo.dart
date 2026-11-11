import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:luminthor/core/branding/brand_assets.dart';

enum LogoPart { symbol, wordmark, full }

/// Renders the supplied SVG artwork at its original proportions.
class LuminthorLogo extends StatelessWidget {
  final bool isDark;
  final double width;
  final LogoPart part;

  const LuminthorLogo({
    super.key,
    required this.isDark,
    this.width = 160,
    this.part = LogoPart.full,
  });

  @override
  Widget build(BuildContext context) {
    final symbolAsset = isDark ? BrandAssets.darkLogo : BrandAssets.lightLogo;
    final wordmarkAsset =
        isDark ? BrandAssets.darkWordmark : BrandAssets.lightWordmark;
    const symbolSize = Size(319, 278);
    const wordmarkSize = Size(848, 135);

    return Semantics(
      image: true,
      label: BrandAssets.name,
      child: SizedBox(
        width: width,
        child: switch (part) {
          LogoPart.symbol => _svg(symbolAsset, symbolSize, width),
          LogoPart.wordmark => _svg(wordmarkAsset, wordmarkSize, width),
          LogoPart.full => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _svg(symbolAsset, symbolSize, width * .4),
                SizedBox(height: width * .015),
                _svg(wordmarkAsset, wordmarkSize, width),
              ],
            ),
        },
      ),
    );
  }

  Widget _svg(String asset, Size size, double targetWidth) {
    return SvgPicture.asset(
      asset,
      width: targetWidth,
      height: targetWidth * size.height / size.width,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
