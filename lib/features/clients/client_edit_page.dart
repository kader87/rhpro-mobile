import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_models.dart';
import 'client_providers.dart';

class ClientEditPage extends ConsumerStatefulWidget {
  const ClientEditPage({super.key, this.client});

  final Client? client;

  @override
  ConsumerState<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends ConsumerState<ClientEditPage> {
  late final _name = TextEditingController(text: widget.client?.name);
  late final _email = TextEditingController(text: widget.client?.email);
  late final _phone = TextEditingController(text: widget.client?.phone);
  late final _address = TextEditingController(text: widget.client?.address);
  late final _city = TextEditingController(text: widget.client?.city);
  late final _postalCode = TextEditingController(text: widget.client?.postalCode);
  late final _description = TextEditingController(text: widget.client?.description);
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _city, _postalCode, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Le nom est obligatoire.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final draft = Client(
      id: widget.client?.id ?? '',
      name: _name.text.trim(),
      active: widget.client?.active ?? true,
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      postalCode: _postalCode.text.trim().isEmpty ? null : _postalCode.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
    );
    try {
      final api = ref.read(clientApiProvider);
      if (widget.client == null) {
        await api.create(draft);
      } else {
        await api.update(widget.client!.id, draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? 'Nouveau client' : 'Modifier le client')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom *')),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Adresse')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _postalCode, decoration: const InputDecoration(labelText: 'Code postal'))),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: TextField(controller: _city, decoration: const InputDecoration(labelText: 'Ville'))),
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
