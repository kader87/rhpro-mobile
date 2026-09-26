import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import 'auth_api.dart';
import 'auth_models.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioProvider = Provider((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return buildDioClient(
    tokenStorage,
    onUnauthenticated: () => ref.read(authControllerProvider.notifier).logout(),
  );
});

final authApiProvider = Provider((ref) => AuthApi(ref.watch(dioProvider)));

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);

/// Holds the current session: `null` when logged out, an [AuthUser] once logged in.
class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    final token = await ref.watch(tokenStorageProvider).readAccessToken();
    if (token == null) return null;
    try {
      return await ref.read(authApiProvider).me();
    } on Object {
      // Token expired/invalid: the dio interceptor already cleared it on a 401.
      return null;
    }
  }

  Future<void> login({required String email, required String password, bool rememberMe = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authApiProvider).login(email: email, password: password, rememberMe: rememberMe);
      await ref.read(tokenStorageProvider).save(accessToken: session.token, refreshToken: session.refreshToken);
      return session.user;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}
