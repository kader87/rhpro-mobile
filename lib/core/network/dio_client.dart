import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

/// Builds the shared [Dio] instance used to call the RH Pro REST API.
///
/// The backend has no `/api/auth/refresh` endpoint yet even though it issues a
/// refresh token at login (see `AuthResponse.refreshToken`); until that endpoint
/// exists, a 401 just clears the stored session and forces a fresh login.
Dio buildDioClient(TokenStorage tokenStorage, {required void Function() onUnauthenticated}) {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl, contentType: 'application/json'));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await tokenStorage.clear();
          onUnauthenticated();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
