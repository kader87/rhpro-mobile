/// Authenticated user, limited to what the mobile app currently needs.
/// Mirrors a subset of the backend's `UserResponse` (fr.rhpro.dto.response).
class AuthUser {
  AuthUser({required this.id, required this.firstName, required this.lastName, required this.email, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String,
        role: json['role'] as String,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  String get fullName => '$firstName $lastName'.trim();
}

/// Mirrors the backend's `AuthResponse` (fr.rhpro.dto.response).
class AuthSession {
  AuthSession({required this.token, required this.refreshToken, required this.user, required this.passwordChangeRequired});

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String?,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        passwordChangeRequired: json['passwordChangeRequired'] as bool? ?? false,
      );

  final String token;
  final String? refreshToken;
  final AuthUser user;
  final bool passwordChangeRequired;
}
