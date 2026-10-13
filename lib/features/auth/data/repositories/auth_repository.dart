import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepository({
    required ApiClient apiClient,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient,
        _storage = storage ?? const FlutterSecureStorage();

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final authData = AuthResponseModel.fromJson(response.data);
    await _apiClient.saveToken(authData.accessToken);
    await _storage.write(
      key: ApiClient.userKey,
      value: jsonEncode(authData.user.toJson()),
    );

    return authData;
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
    String? jobTitle,
    String? department,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (jobTitle != null && jobTitle.isNotEmpty) 'jobTitle': jobTitle,
        if (department != null && department.isNotEmpty) 'department': department,
      },
    );

    final authData = AuthResponseModel.fromJson(response.data);
    await _apiClient.saveToken(authData.accessToken);
    await _storage.write(
      key: ApiClient.userKey,
      value: jsonEncode(authData.user.toJson()),
    );

    return authData;
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get('/auth/me');
    final user = UserModel.fromJson(response.data);
    await _storage.write(
      key: ApiClient.userKey,
      value: jsonEncode(user.toJson()),
    );
    return user;
  }

  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: ApiClient.userKey);
    if (raw != null) {
      try {
        return UserModel.fromJson(jsonDecode(raw));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<bool> hasToken() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _apiClient.clearAuth();
  }
}
