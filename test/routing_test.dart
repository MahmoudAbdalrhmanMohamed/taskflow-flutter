import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/core/routing/app_router.dart';
import 'package:taskflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('App Router Guard & Redirect Tests', () {
    test('Router initial location defaults to /splash for smooth launch experience', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router.routeInformationProvider.value.uri.path, equals('/splash'));
    });

    test('While initializing, stays on splash or redirects to splash', () {
      const uninitializedState = AuthState(
        isInitialized: false,
        isAuthenticated: false,
      );

      // On splash: stays on splash
      expect(
        appRouterRedirect(authState: uninitializedState, location: '/splash'),
        isNull,
      );

      // Attempt to access dashboard before initialization: redirected to /splash
      expect(
        appRouterRedirect(authState: uninitializedState, location: '/dashboard'),
        equals('/splash'),
      );

      // Attempt to access login before initialization: redirected to /splash
      expect(
        appRouterRedirect(authState: uninitializedState, location: '/login'),
        equals('/splash'),
      );
    });

    test('Unauthenticated user is redirected to /login directly from splash without seeing dashboard', () {
      const unauthenticatedState = AuthState(
        isInitialized: true,
        isAuthenticated: false,
      );

      // From splash -> direct to /login
      expect(
        appRouterRedirect(authState: unauthenticatedState, location: '/splash'),
        equals('/login'),
      );

      // On login -> allowed
      expect(
        appRouterRedirect(authState: unauthenticatedState, location: '/login'),
        isNull,
      );

      // On register -> allowed
      expect(
        appRouterRedirect(authState: unauthenticatedState, location: '/register'),
        isNull,
      );

      // Protected routes -> blocked and sent to /login
      expect(
        appRouterRedirect(authState: unauthenticatedState, location: '/dashboard'),
        equals('/login'),
      );
      expect(
        appRouterRedirect(authState: unauthenticatedState, location: '/projects'),
        equals('/login'),
      );
      expect(
        appRouterRedirect(authState: unauthenticatedState, location: '/tasks'),
        equals('/login'),
      );
    });

    test('Authenticated user is redirected to /dashboard and away from auth screens', () {
      final authenticatedState = AuthState(
        isInitialized: true,
        isAuthenticated: true,
        user: UserModel(
          id: '1',
          email: 'demo@taskflow.dev',
          name: 'Demo User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // From splash -> direct to /dashboard
      expect(
        appRouterRedirect(authState: authenticatedState, location: '/splash'),
        equals('/dashboard'),
      );

      // Trying to visit login -> redirected to /dashboard
      expect(
        appRouterRedirect(authState: authenticatedState, location: '/login'),
        equals('/dashboard'),
      );

      // Trying to visit register -> redirected to /dashboard
      expect(
        appRouterRedirect(authState: authenticatedState, location: '/register'),
        equals('/dashboard'),
      );

      // On dashboard -> allowed
      expect(
        appRouterRedirect(authState: authenticatedState, location: '/dashboard'),
        isNull,
      );

      // On projects -> allowed
      expect(
        appRouterRedirect(authState: authenticatedState, location: '/projects'),
        isNull,
      );
    });
  });
}
