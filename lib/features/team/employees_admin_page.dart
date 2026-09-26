import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'employee_edit_page.dart';
import 'employee_providers.dart';

class EmployeesAdminPage extends ConsumerWidget {
  const EmployeesAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Employés')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const EmployeeEditPage()));
          if (saved == true) ref.invalidate(allUsersProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allUsersProvider),
        child: users.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];
              return ListTile(
                leading: CircleAvatar(child: Text(e.firstName.isNotEmpty ? e.firstName[0] : '?')),
                title: Text(e.fullName, style: TextStyle(color: (e.active ?? true) ? null : Colors.grey)),
                subtitle: Text('${e.role} · ${e.department ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final saved = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => EmployeeEditPage(employee: e)),
                        );
                        if (saved == true) ref.invalidate(allUsersProvider);
                      },
                    ),
                    Switch(
                      value: e.active ?? true,
                      onChanged: (v) async {
                        final api = ref.read(employeeApiProvider);
                        if (v) {
                          await api.activate(e.id);
                        } else {
                          await api.deactivate(e.id);
                        }
                        ref.invalidate(allUsersProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
