import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/app/app.dart';
import 'package:luminthor/app/bootstrap/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageError = await initializeStorage();

  runApp(
    ProviderScope(
      child: MyApp(initialization: initializeEngine(storageError)),
    ),
  );
}
