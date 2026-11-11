import 'package:luminthor/features/workspace/domain/entities/workspace.dart';

abstract interface class WorkspaceRepository {
  Workspace load();

  /// Persists [workspace]; failures are propagated to the caller.
  Future<void> save(Workspace workspace);
}
