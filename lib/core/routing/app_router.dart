import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/projects/presentation/screens/projects_list_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/tasks/presentation/screens/tasks_list_screen.dart';
import '../../features/tasks/presentation/screens/kanban_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

String? appRouterRedirect({
  required AuthState authState,
  required String location,
}) {
  final isSplash = location == '/splash';
  final isLoggingIn = location == '/login';
  final isRegistering = location == '/register';

  // Keep user on the branded splash loader until auth completes checking
  if (!authState.isInitialized) {
    return isSplash ? null : '/splash';
  }

  final isAuth = authState.isAuthenticated;

  // Once initialized: if still on splash, transition directly to dashboard or login
  if (isSplash) {
    return isAuth ? '/dashboard' : '/login';
  }

  // Block unauthenticated access to protected pages
  if (!isAuth && !isLoggingIn && !isRegistering) {
    return '/login';
  }

  // Redirect authenticated users away from login/register to dashboard
  if (isAuth && (isLoggingIn || isRegistering)) {
    return '/dashboard';
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier)),
    redirect: (context, state) => appRouterRedirect(
      authState: authState,
      location: state.uri.path,
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: id);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsListScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksListScreen(),
          ),
          GoRoute(
            path: '/kanban',
            builder: (context, state) => const KanbanScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(StateNotifier notifier) {
    notifier.addListener((_) {
      notifyListeners();
    });
  }
}
