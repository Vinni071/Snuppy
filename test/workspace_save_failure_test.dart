import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/app.dart';
import 'package:luminthor/app/router/app_router.dart';
import 'package:luminthor/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:luminthor/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

/// Repository whose writes fail on demand or wait for the test to finish them.
class ControlledWorkspaceRepository implements WorkspaceRepository {
  bool fail = false;
  final List<Completer<void>> pending = [];
  bool holdWrites = false;

  @override
  Workspace load() => const Workspace(documents: []);

  @override
  Future<void> save(Workspace workspace) {
    if (holdWrites) {
      final completer = Completer<void>();
      pending.add(completer);
      return completer.future;
    }
    if (fail) return Future.error(StateError('disco cheio'));
    return Future.value();
  }
}

void main() {
  test('A failed autosave is flagged and cleared by the next successful save',
      () async {
    final repository = ControlledWorkspaceRepository()..fail = true;
    final container = ProviderContainer(overrides: [
      workspaceRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    final workspace = container.read(workspaceProvider.notifier);

    workspace.create(name: 'falha.lumi', source: 'print(1);');
    await pumpEventQueue();
    expect(container.read(workspaceSaveFailedProvider), isTrue);
    // The edit stays available in memory even though it was not written.
    expect(container.read(workspaceProvider).activeDocument?.source,
        'print(1);');

    repository.fail = false;
    workspace.updateSource('print(2);');
    await pumpEventQueue();
    expect(container.read(workspaceSaveFailedProvider), isFalse);
  });

  test('An older failed save does not override a newer successful one',
      () async {
    final repository = ControlledWorkspaceRepository()..holdWrites = true;
    final container = ProviderContainer(overrides: [
      workspaceRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    final workspace = container.read(workspaceProvider.notifier);

    workspace.create(name: 'ordem.lumi', source: 'print(1);');
    workspace.updateSource('print(2);');
    expect(repository.pending, hasLength(2));

    repository.pending[1].complete();
    await pumpEventQueue();
    repository.pending[0].completeError(StateError('gravação antiga'));
    await pumpEventQueue();

    expect(container.read(workspaceSaveFailedProvider), isFalse);
  });

  testWidgets('The app warns visibly when edits cannot be saved',
      (tester) async {
    final repository = ControlledWorkspaceRepository()..fail = true;
    final container = ProviderContainer(overrides: [
      workspaceRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    AppRouter.router.go('/');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MyApp(showSplash: false),
    ));
    await tester.pumpAndSettle();

    container
        .read(workspaceProvider.notifier)
        .create(name: 'aviso.lumi', source: 'print(1);');
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Não foi possível salvar o arquivo'),
        findsOneWidget);

    repository.fail = false;
    container.read(workspaceProvider.notifier).updateSource('print(2);');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Alterações salvas.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
