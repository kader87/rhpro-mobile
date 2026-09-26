import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import 'timesheet_models.dart';
import 'timesheet_providers.dart';

class NewTimesheetEntryPage extends ConsumerStatefulWidget {
  const NewTimesheetEntryPage({super.key});

  @override
  ConsumerState<NewTimesheetEntryPage> createState() => _NewTimesheetEntryPageState();
}

class _NewTimesheetEntryPageState extends ConsumerState<NewTimesheetEntryPage> {
  Activity? _activity;
  DateTime _date = DateTime.now();
  TimesheetUnit _unit = TimesheetUnit.hours;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (_activity == null || amount == null || amount <= 0) {
      setState(() => _error = 'Sélectionne une activité et une quantité valide.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(timesheetApiProvider).addEntry(
            activityId: _activity!.id,
            entryDate: _date,
            amount: amount,
            unit: _unit,
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Erreur lors de l\'enregistrement : $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activeActivitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle saisie')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          activities.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Impossible de charger les activités : $e'),
            data: (list) => DropdownButtonFormField<Activity>(
              value: _activity,
              decoration: const InputDecoration(labelText: 'Activité'),
              items: list.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
              onChanged: (v) => setState(() => _activity = v),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(formatDateDisplay(_date)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quantité'),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<TimesheetUnit>(
                value: _unit,
                items: TimesheetUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(u.label))).toList(),
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note (optionnel)'),
            maxLines: 2,
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
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
