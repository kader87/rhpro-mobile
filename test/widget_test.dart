import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rhpro_mobile/features/auth/auth_models.dart';
import 'package:rhpro_mobile/features/auth/auth_providers.dart';
import 'package:rhpro_mobile/main.dart';

/// Skips the real secure-storage plugin (unavailable in widget tests) and
/// reports "logged out" immediately.
class _LoggedOutAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => null;
}

void main() {
  testWidgets('Shows the login screen when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(_LoggedOutAuthController.new)],
        child: const RhProApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RH Pro'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
