import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient: apiClient);
});

class AuthState {
  final bool isInitialized;
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final hasToken = await _repository.hasToken();
      if (!hasToken) {
        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
        return;
      }

      // Try reading cached user first for instant UI response
      final cachedUser = await _repository.getCachedUser();
      if (cachedUser != null) {
        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: true,
          user: cachedUser,
          isLoading: false,
        );
      }

      // Fetch fresh profile in background
      final freshUser = await _repository.getProfile();
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: true,
        user: freshUser,
        isLoading: false,
      );
    } catch (e) {
      // If profile fetch fails but token exists, check if 401
      final hasToken = await _repository.hasToken();
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: hasToken,
        isLoading: false,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.login(email: email, password: password);
      state = state.copyWith(
        isAuthenticated: true,
        user: result.user,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      final rawError = e.toString();
      String userFriendlyMessage = rawError;
      if (rawError.contains('localhost:5432') || rawError.contains('reach database server')) {
        userFriendlyMessage =
            'Database is not connected on Vercel. Please set DATABASE_URL to your Neon connection string in Vercel Settings.';
      } else if (rawError.contains('Cannot connect to server')) {
        userFriendlyMessage =
            'Cannot reach API server. Check connection or launch in Offline Demo Mode.';
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyMessage,
      );
      return false;
    }
  }

  void loginDemoOffline() {
    final now = DateTime.now();
    state = state.copyWith(
      isInitialized: true,
      isAuthenticated: true,
      user: UserModel(
        id: 'demo-user-id',
        email: 'demo@taskflow.dev',
        name: 'Alex Morgan',
        jobTitle: 'Senior Full-Stack Engineer',
        department: 'Product Engineering',
        avatarUrl: null,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? jobTitle,
    String? department,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.register(
        email: email,
        password: password,
        name: name,
        jobTitle: jobTitle,
        department: department,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: result.user,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState(
      isInitialized: true,
      isAuthenticated: false,
      user: null,
      isLoading: false,
    );
  }

  void setUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
