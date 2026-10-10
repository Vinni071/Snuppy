import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/compiler/engine_library_path.dart';

void main() {
  test('Linux selects the native library packaged beside the executable',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('luminthor-bundle-');
    addTearDown(() => directory.delete(recursive: true));
    final executable = '${directory.path}/luminthor';
    final library = File('${directory.path}/lib/libide_engine.so');
    await library.parent.create();
    await library.writeAsBytes([]);
    expect(bundledEngineLibraryPath(executablePath: executable), library.path);
  }, skip: !Platform.isLinux);

  test('An unpackaged process can use the default library loader', () async {
    final directory =
        await Directory.systemTemp.createTemp('luminthor-no-bundle-');
    addTearDown(() => directory.delete(recursive: true));
    expect(
        bundledEngineLibraryPath(executablePath: '${directory.path}/luminthor'),
        isNull);
  });
}
