import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'prospect_models.dart';
import 'prospect_providers.dart';

class ProspectDetailPage extends ConsumerStatefulWidget {
  const ProspectDetailPage({super.key, required this.prospect});

  final Prospect prospect;

  @override
  ConsumerState<ProspectDetailPage> createState() => _ProspectDetailPageState();
}

class _ProspectDetailPageState extends ConsumerState<ProspectDetailPage> {
  late Prospect _prospect = widget.prospect;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(ProspectStatus status) async {
    final updated = await ref.read(prospectApiProvider).updateStatus(_prospect, status);
    setState(() => _prospect = updated);
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final updated = await ref.read(prospectApiProvider).addComment(_prospect.id, _commentController.text.trim());
    setState(() => _prospect = updated);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final devis = ref.watch(devisForProspectProvider(_prospect.id));

    return Scaffold(
      appBar: AppBar(title: Text(_prospect.companyName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_prospect.contactName, style: Theme.of(context).textTheme.titleMedium),
          if (_prospect.email != null) Text(_prospect.email!),
          if (_prospect.phone != null) Text(_prospect.phone!),
          const SizedBox(height: 16),
          DropdownButtonFormField<ProspectStatus>(
            value: _prospect.status,
            decoration: const InputDecoration(labelText: 'Statut'),
            items: ProspectStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
            onChanged: (s) => s != null ? _changeStatus(s) : null,
          ),
          if (_prospect.status == ProspectStatus.transforme)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.icon(
                icon: const Icon(Icons.business),
                label: const Text('Convertir en client'),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(prospectApiProvider).convertToClient(_prospect);
                  messenger.showSnackBar(const SnackBar(content: Text('Client créé.')));
                },
              ),
            ),
          const Divider(height: 32),
          Text('Devis', style: Theme.of(context).textTheme.titleMedium),
          devis.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Erreur : $e'),
            data: (list) => Column(
              children: list
                  .map((d) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(d.devisNumber),
                        subtitle: Text('${d.status.label} · ${d.totalTtc.toStringAsFixed(2)} € TTC'),
                      ))
                  .toList(),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Nouveau devis simple'),
            onPressed: () async {
              await ref.read(prospectApiProvider).createDevis(
                prospectId: _prospect.id,
                prospectName: _prospect.companyName,
                lines: [DevisLine(description: 'Prestation', quantity: 1, unit: 'jour', unitPrice: 500, taxRate: 20)],
              );
              ref.invalidate(devisForProspectProvider(_prospect.id));
            },
          ),
          const Divider(height: 32),
          Text('Commentaires', style: Theme.of(context).textTheme.titleMedium),
          ..._prospect.comments.map((c) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c.text),
                subtitle: Text('${c.author} · ${formatDateDisplay(c.createdAt)}'),
              )),
          Row(
            children: [
              Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(labelText: 'Ajouter un commentaire'))),
              IconButton(icon: const Icon(Icons.send), onPressed: _addComment),
            ],
          ),
        ],
      ),
    );
  }
}
