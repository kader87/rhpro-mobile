import 'package:flutter/foundation.dart';

/// Base URL of the RH Pro backend.
///
/// Override at build/run time with `--dart-define=API_BASE_URL=https://rhpro-app.fr`.
/// Default targets the Android emulator's alias for the host machine's localhost;
/// a physical device needs the host's LAN IP instead. Must not import `dart:io`
/// (its `Platform` throws on Flutter Web) — `defaultTargetPlatform` works on every target.
String get apiBaseUrl {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;
  if (kIsWeb) return 'http://localhost:8080';
  final host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  return 'http://$host:8080';
}
