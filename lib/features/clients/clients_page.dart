import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'client_edit_page.dart';
import 'client_providers.dart';

const _managerRoles = {'MANAGER', 'ADMIN', 'SUPER_ADMIN'};

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final canEdit = _managerRoles.contains(ref.watch(authControllerProvider).value?.role);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () async {
                final saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const ClientEditPage()),
                );
                if (saved == true) ref.invalidate(clientsProvider);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(clientsProvider),
        child: clients.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun client.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(c.name.isNotEmpty ? c.name[0] : '?')),
                  title: Text(c.name, style: TextStyle(color: c.active ? null : Colors.grey)),
                  subtitle: Text([c.city, c.email].whereType<String>().join(' · ')),
                  trailing: canEdit
                      ? IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final saved = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => ClientEditPage(client: c)),
                            );
                            if (saved == true) ref.invalidate(clientsProvider);
                          },
                        )
                      : null,
                  onLongPress: canEdit
                      ? () async {
                          await ref.read(clientApiProvider).toggleActive(c.id);
                          ref.invalidate(clientsProvider);
                        }
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
