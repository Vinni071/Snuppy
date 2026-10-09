import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_assets.dart';
import '../../../core/branding/luminthor_logo.dart';
import '../data/splash_player.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool initializationReady;
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.initializationReady,
    required this.onComplete,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  SplashPlayer? _player;
  StreamSubscription<bool>? _completedSubscription;
  StreamSubscription<String>? _errorSubscription;
  Timer? _watchdog;
  Timer? _fallbackTimer;
  bool _started = false;
  bool _isDark = true;
  bool _firstFrameReady = false;
  bool _completed = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _isDark = Theme.of(context).brightness == Brightness.dark;
    if (MediaQuery.disableAnimationsOf(context)) {
      _fallbackTimer = Timer(const Duration(milliseconds: 300), _finish);
    } else {
      _startVideo();
    }
  }

  Future<void> _startVideo() async {
    // Playback failures or stalled decoders must still let the app open.
    _watchdog = Timer(const Duration(seconds: 15), _finish);
    try {
      final player = ref.read(splashPlayerFactoryProvider)();
      _player = player;
      _completedSubscription = player.completed.listen((completed) {
        if (completed) _finish();
      });
      _errorSubscription = player.errors.listen((error) {
        if (error.isNotEmpty) _usePoster(error);
      });
      await player
          .play(_isDark ? BrandAssets.darkSplash : BrandAssets.lightSplash);
      await player.firstFrame;
      if (mounted && !_completed && !_failed) {
        setState(() => _firstFrameReady = true);
      }
    } catch (error) {
      _usePoster(error);
    }
  }

  void _usePoster(Object error) {
    if (!mounted || _completed || _failed) return;
    debugPrint('Luminthor splash: $error');
    setState(() => _failed = true);
    _fallbackTimer = Timer(const Duration(milliseconds: 700), _finish);
  }

  void _finish() {
    if (!mounted || _completed) return;
    _watchdog?.cancel();
    _fallbackTimer?.cancel();
    setState(() => _completed = true);
    _releasePlayer();
    widget.onComplete();
  }

  void _releasePlayer() {
    _completedSubscription?.cancel();
    _errorSubscription?.cancel();
    _completedSubscription = null;
    _errorSubscription = null;
    final player = _player;
    _player = null;
    if (player != null) {
      unawaited(
          Future<void>.microtask(player.dispose).catchError((Object error) {
        debugPrint('Luminthor splash disposal: $error');
      }));
    }
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _fallbackTimer?.cancel();
    _releasePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = BrandAssets.splashBackground(_isDark);
    final foreground = _isDark ? Colors.white : const Color(0xFF151515);
    return Scaffold(
      key: const ValueKey('luminthor-splash'),
      backgroundColor: background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_player != null && !_completed && !_failed)
            _player!.buildVideo(background),
          if (!_firstFrameReady || _completed || _failed)
            LayoutBuilder(
              builder: (context, constraints) => Center(
                child: LuminthorLogo(
                  isDark: _isDark,
                  width: (constraints.maxWidth * .68)
                      .clamp(0.0, 460.0)
                      .toDouble(),
                ),
              ),
            ),
          SafeArea(
            minimum: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!_completed)
                  TextButton(
                    key: const ValueKey('skip-splash'),
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                        foregroundColor: foreground.withValues(alpha: .7)),
                    child: const Text('Pular', style: TextStyle(fontSize: 13)),
                  ),
                const Spacer(),
                if (_completed && !widget.initializationReady)
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: foreground)),
                    const SizedBox(height: 12),
                    Text('Preparando seu espaço...',
                        style: TextStyle(
                            color: foreground.withValues(alpha: .6),
                            fontSize: 12)),
                  ])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
