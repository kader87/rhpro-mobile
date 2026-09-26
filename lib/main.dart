import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_providers.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const ProviderScope(child: RhProApp()));
}

class RhProApp extends StatelessWidget {
  const RhProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RH Pro',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginPage(),
      data: (user) => user == null ? const LoginPage() : const HomePage(),
    );
  }
}
