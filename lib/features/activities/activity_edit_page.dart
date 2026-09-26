import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timesheet_unit.dart';
import '../clients/client_models.dart';
import '../clients/client_providers.dart';
import 'activity_providers.dart';

class ActivityEditPage extends ConsumerStatefulWidget {
  const ActivityEditPage({super.key});

  @override
  ConsumerState<ActivityEditPage> createState() => _ActivityEditPageState();
}

class _ActivityEditPageState extends ConsumerState<ActivityEditPage> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  Client? _client;
  TimesheetUnit _unit = TimesheetUnit.hours;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _client == null) {
      setState(() => _error = 'Le nom et le client sont obligatoires.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(billableActivityApiProvider).create(
            name: _name.text.trim(),
            clientId: _client!.id,
            pricingUnit: _unit,
            description: _description.text.trim().isEmpty ? null : _description.text.trim(),
            price: double.tryParse(_price.text.replaceAll(',', '.')),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle activité')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom *')),
          const SizedBox(height: 12),
          clients.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Impossible de charger les clients : $e'),
            data: (list) => DropdownButtonFormField<Client>(
              value: _client,
              decoration: const InputDecoration(labelText: 'Client *'),
              items: list.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _client = v),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Prix'),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<TimesheetUnit>(
                value: _unit,
                items: TimesheetUnit.values.map((u) => DropdownMenuItem(value: u, child: Text('/ ${u.label}'))).toList(),
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
