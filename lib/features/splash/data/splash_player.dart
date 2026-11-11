import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SplashPlayer {
  Stream<bool> get completed;
  Stream<String> get errors;
  Future<void> get firstFrame;
  Future<void> play(String asset);
  Widget buildVideo(Color background);
  Future<void> dispose();
}

/// Plays an animated image asset (GIF/WebP) exactly once, whatever its loop
/// setting.
class AnimatedImageSplashPlayer implements SplashPlayer {
  final _completed = StreamController<bool>.broadcast();
  final _errors = StreamController<String>.broadcast();
  final _firstFrame = Completer<void>();
  final _frame = ValueNotifier<ui.Image?>(null);
  ui.Codec? _codec;
  Timer? _timer;
  bool _disposed = false;

  @override
  Stream<bool> get completed => _completed.stream;

  @override
  Stream<String> get errors => _errors.stream;

  @override
  Future<void> get firstFrame => _firstFrame.future;

  @override
  Future<void> play(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final buffer = await ui.ImmutableBuffer.fromUint8List(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      buffer.dispose();
      if (_disposed) {
        descriptor.dispose();
        return;
      }
      _codec = await descriptor.instantiateCodec();
      descriptor.dispose();
      await _showFrame(0);
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> _showFrame(int index) async {
    final codec = _codec;
    if (_disposed || codec == null) return;
    if (index >= codec.frameCount) {
      if (!_completed.isClosed) _completed.add(true);
      return;
    }
    try {
      final info = await codec.getNextFrame();
      if (_disposed) {
        info.image.dispose();
        return;
      }
      _frame.value?.dispose();
      _frame.value = info.image;
      if (!_firstFrame.isCompleted) _firstFrame.complete();
      final delay = info.duration > Duration.zero
          ? info.duration
          : const Duration(milliseconds: 100);
      _timer = Timer(delay, () => _showFrame(index + 1));
    } catch (error) {
      _fail(error);
    }
  }

  void _fail(Object error) {
    if (!_firstFrame.isCompleted) _firstFrame.completeError(error);
    if (!_errors.isClosed) _errors.add(error.toString());
  }

  @override
  Widget buildVideo(Color background) => ColoredBox(
        color: background,
        child: ValueListenableBuilder<ui.Image?>(
          valueListenable: _frame,
          builder: (context, image, _) => image == null
              ? const SizedBox.expand()
              : RawImage(
                  image: image,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
        ),
      );

  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    _codec?.dispose();
    _codec = null;
    // The splash widget may still be listening until its next rebuild, so the
    // notifier is cleared instead of disposed.
    final last = _frame.value;
    _frame.value = null;
    last?.dispose();
    if (!_firstFrame.isCompleted) {
      _firstFrame.future.ignore();
      _firstFrame.completeError(StateError('Splash disposed'));
    }
    await _completed.close();
    await _errors.close();
  }
}

final splashPlayerFactoryProvider =
    Provider<SplashPlayer Function()>((ref) => AnimatedImageSplashPlayer.new);
