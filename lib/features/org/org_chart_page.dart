import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../team/employee_models.dart';
import '../team/employee_providers.dart';

/// No dedicated backend endpoint exists for an org chart — like the web app,
/// this derives a manager-grouped view client-side from the users the current
/// role can already see (admins: everyone; managers: their team; employees:
/// their department colleagues).
class OrgChartPage extends ConsumerWidget {
  const OrgChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).value?.role;
    final AsyncValue<List<EmployeeSummary>> source = switch (role) {
      'ADMIN' || 'SUPER_ADMIN' => ref.watch(allActiveEmployeesProvider),
      'MANAGER' => ref.watch(myTeamProvider),
      _ => ref.watch(departmentColleaguesProvider),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Organigramme')),
      body: source.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          final byManager = <String, List<EmployeeSummary>>{};
          for (final e in list) {
            byManager.putIfAbsent(e.managerName ?? 'Sans manager', () => []).add(e);
          }
          final managers = byManager.keys.toList()..sort();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: managers.map((manager) {
              return ExpansionTile(
                title: Text(manager, style: const TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: true,
                children: byManager[manager]!
                    .map((e) => ListTile(
                          leading: CircleAvatar(child: Text(e.firstName.isNotEmpty ? e.firstName[0] : '?')),
                          title: Text(e.fullName),
                          subtitle: Text(e.department ?? e.role),
                        ))
                    .toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
