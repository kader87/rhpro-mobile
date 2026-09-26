import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prospect_models.dart';
import 'prospect_providers.dart';
import 'prospect_detail_page.dart';

class ProspectsPage extends ConsumerWidget {
  const ProspectsPage({super.key});

  Color _statusColor(ProspectStatus s) => switch (s) {
        ProspectStatus.aContacter => Colors.blueGrey,
        ProspectStatus.contacte => Colors.blue,
        ProspectStatus.devisEnvoye => Colors.orange,
        ProspectStatus.relance => Colors.purple,
        ProspectStatus.transforme => Colors.green,
        ProspectStatus.perdu => Colors.red,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prospects = ref.watch(prospectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prospects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewProspectDialog());
          if (created == true) ref.invalidate(prospectsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(prospectsProvider),
        child: prospects.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun prospect.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                return ListTile(
                  title: Text(p.companyName),
                  subtitle: Text(p.contactName),
                  trailing: Chip(
                    label: Text(p.status.label, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    backgroundColor: _statusColor(p.status),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProspectDetailPage(prospect: p))),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NewProspectDialog extends ConsumerStatefulWidget {
  const _NewProspectDialog();

  @override
  ConsumerState<_NewProspectDialog> createState() => _NewProspectDialogState();
}

class _NewProspectDialogState extends ConsumerState<_NewProspectDialog> {
  final _company = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau prospect'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _company, decoration: const InputDecoration(labelText: 'Entreprise *')),
            TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Contact *')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: _submitting
              ? null
              : () async {
                  if (_company.text.trim().isEmpty || _contact.text.trim().isEmpty) return;
                  setState(() => _submitting = true);
                  await ref.read(prospectApiProvider).create(
                        companyName: _company.text.trim(),
                        contactName: _contact.text.trim(),
                        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
                        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context, true);
                },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
