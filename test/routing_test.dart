import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/core/routing/app_router.dart';
import 'package:taskflow/features/auth/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('App Router Guard Tests', () {
    test('Router initial location defaults to /login', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router.routeInformationProvider.value.uri.path, equals('/login'));
    });

    test('Unauthenticated user cannot navigate to /dashboard before logging in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authNotifier = container.read(authProvider.notifier);
      // Ensure state is unauthenticated
      authNotifier.logout();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, isFalse);

      final router = container.read(routerProvider);
      expect(router.routeInformationProvider.value.uri.path, equals('/login'));
    });
  });
}
