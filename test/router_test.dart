import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/router/app_router.dart';
import 'package:luminthor/features/home/presentation/screens/home_screen.dart';
import 'package:luminthor/features/settings/presentation/screens/settings_screen.dart';

import 'widget_test.dart' show pumpApp;

void main() {
  testWidgets('Unknown locations fall back to Home', (tester) async {
    await pumpApp(tester);
    AppRouter.router.go(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    AppRouter.router.go('/rota-que-nao-existe');
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
