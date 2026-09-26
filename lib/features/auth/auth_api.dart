import 'package:dio/dio.dart';

import 'auth_models.dart';

/// Calls the backend's `/api/auth` endpoints (fr.rhpro.controller.AuthController).
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthSession> login({required String email, required String password, bool rememberMe = false}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'password': password, 'rememberMe': rememberMe},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<AuthUser> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/auth/me');
    return AuthUser.fromJson(response.data!);
  }
}
