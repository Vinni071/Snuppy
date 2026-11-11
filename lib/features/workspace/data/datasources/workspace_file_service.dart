import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportedSource {
  final String name;
  final String source;

  const ImportedSource({required this.name, required this.source});
}

class WorkspaceFileService {
  Future<ImportedSource?> open() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Abrir arquivo Lumi',
      type: FileType.custom,
      allowedExtensions: ['lumi', 'txt'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    // Reject binary/non-UTF-8 files rather than silently corrupting their code.
    final source = utf8.decode(bytes).replaceFirst(RegExp(r'^\uFEFF'), '');
    if (source.contains('\u0000')) {
      throw const FormatException('O arquivo não contém código de texto.');
    }
    return ImportedSource(name: file.name, source: source);
  }

  Future<bool> export({required String name, required String source}) async {
    final destination = await FilePicker.saveFile(
      dialogTitle: 'Exportar arquivo Lumi',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: ['lumi', 'txt'],
      bytes: Uint8List.fromList(utf8.encode(source)),
      mimeType: 'text/plain',
    );
    return destination != null;
  }
}

final workspaceFileServiceProvider =
    Provider<WorkspaceFileService>((ref) => WorkspaceFileService());
