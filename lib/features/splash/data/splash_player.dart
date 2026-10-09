import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/branding/brand_assets.dart';

abstract class SplashPlayer {
  Stream<bool> get completed;
  Stream<String> get errors;
  Future<void> get firstFrame;
  Future<void> play(String asset);
  Widget buildVideo(Color background);
  Future<void> dispose();
}

class MediaKitSplashPlayer implements SplashPlayer {
  late final Player _player;
  late final VideoController _video;

  MediaKitSplashPlayer() {
    MediaKit.ensureInitialized();
    _player = Player(
        configuration: const PlayerConfiguration(title: BrandAssets.name));
    // libmpv's Wayland VA-API path can crash the Linux process while creating
    // the splash texture, before Dart can handle a playback error.
    _video = VideoController(
      _player,
      configuration: VideoControllerConfiguration(
        hwdec: defaultTargetPlatform == TargetPlatform.linux ? 'no' : null,
        enableHardwareAcceleration:
            defaultTargetPlatform != TargetPlatform.linux,
      ),
    );
  }

  @override
  Stream<bool> get completed => _player.stream.completed;

  @override
  Stream<String> get errors => _player.stream.error;

  @override
  Future<void> get firstFrame => _video.waitUntilFirstFrameRendered;

  @override
  Future<void> play(String asset) async {
    // A silent splash also supports browser autoplay without a user gesture.
    await _player.setVolume(0);
    await _player.open(Media('asset:///$asset'));
  }

  @override
  Widget buildVideo(Color background) => Video(
        controller: _video,
        fit: BoxFit.contain,
        fill: background,
        controls: NoVideoControls,
        wakelock: false,
        pauseUponEnteringBackgroundMode: true,
        resumeUponEnteringForegroundMode: true,
      );

  @override
  Future<void> dispose() => _player.dispose();
}

final splashPlayerFactoryProvider =
    Provider<SplashPlayer Function()>((ref) => MediaKitSplashPlayer.new);
