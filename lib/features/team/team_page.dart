import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'employee_providers.dart';
import 'employee_detail_page.dart';

class TeamPage extends ConsumerWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(myTeamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon équipe')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myTeamProvider),
        child: team.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun collaborateur.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final e = list[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(e.firstName.isNotEmpty ? e.firstName[0] : '?')),
                  title: Text(e.fullName),
                  subtitle: Text(e.department ?? e.role),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EmployeeDetailPage(employeeId: e.id)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
