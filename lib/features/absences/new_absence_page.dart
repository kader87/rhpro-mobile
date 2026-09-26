import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'absence_models.dart';
import 'absence_providers.dart';

class NewAbsencePage extends ConsumerStatefulWidget {
  const NewAbsencePage({super.key});

  @override
  ConsumerState<NewAbsencePage> createState() => _NewAbsencePageState();
}

class _NewAbsencePageState extends ConsumerState<NewAbsencePage> {
  AbsenceType _type = AbsenceType.paidLeave;
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      setState(() => _error = 'Sélectionne une date de début et de fin.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(absenceApiProvider).create(
            type: _type,
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Erreur lors de la création : $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle demande')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<AbsenceType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type d\'absence'),
            items: AbsenceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de début'),
            subtitle: Text(_startDate == null ? 'Non définie' : formatDateDisplay(_startDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(isStart: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de fin'),
            subtitle: Text(_endDate == null ? 'Non définie' : formatDateDisplay(_endDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(isStart: false),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(labelText: 'Motif (optionnel)'),
            maxLines: 3,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
  }
}
