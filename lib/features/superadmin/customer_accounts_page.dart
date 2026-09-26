import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'superadmin_providers.dart';

class CustomerAccountsPage extends ConsumerWidget {
  const CustomerAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(customerAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Comptes clients')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewAccountDialog());
          if (created == true) ref.invalidate(customerAccountsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(customerAccountsProvider),
        child: accounts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final a = list[i];
              return ListTile(
                title: Text(a.name, style: TextStyle(color: a.active ? null : Colors.grey)),
                subtitle: Text('${a.code} · ${a.currentUserCount ?? 0}/${a.maxUsers ?? '∞'} utilisateurs'),
                trailing: Switch(
                  value: a.active,
                  onChanged: (v) async {
                    final api = ref.read(superAdminApiProvider);
                    if (v) {
                      await api.activateAccount(a.id);
                    } else {
                      await api.deactivateAccount(a.id);
                    }
                    ref.invalidate(customerAccountsProvider);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewAccountDialog extends ConsumerStatefulWidget {
  const _NewAccountDialog();

  @override
  ConsumerState<_NewAccountDialog> createState() => _NewAccountDialogState();
}

class _NewAccountDialogState extends ConsumerState<_NewAccountDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _adminEmail = TextEditingController();
  final _adminFirstName = TextEditingController();
  final _adminLastName = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau compte client'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Entreprise *')),
            TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code *')),
            TextField(controller: _adminEmail, decoration: const InputDecoration(labelText: 'Email admin *')),
            TextField(controller: _adminFirstName, decoration: const InputDecoration(labelText: 'Prénom admin *')),
            TextField(controller: _adminLastName, decoration: const InputDecoration(labelText: 'Nom admin *')),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: _submitting
              ? null
              : () async {
                  if ([_name, _code, _adminEmail, _adminFirstName, _adminLastName].any((c) => c.text.trim().isEmpty)) {
                    setState(() => _error = 'Tous les champs sont obligatoires.');
                    return;
                  }
                  setState(() => _submitting = true);
                  try {
                    await ref.read(superAdminApiProvider).createCustomerAccount(
                          name: _name.text.trim(),
                          code: _code.text.trim(),
                          adminEmail: _adminEmail.text.trim(),
                          adminFirstName: _adminFirstName.text.trim(),
                          adminLastName: _adminLastName.text.trim(),
                        );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    setState(() {
                      _error = 'Erreur : $e';
                      _submitting = false;
                    });
                  }
                },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
