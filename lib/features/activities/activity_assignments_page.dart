import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import '../team/employee_models.dart';
import '../team/employee_providers.dart';
import 'activity_models.dart';
import 'activity_providers.dart';

class ActivityAssignmentsPage extends ConsumerWidget {
  const ActivityAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(activityAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Affectations aux activités')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewAssignmentDialog());
          if (created == true) ref.invalidate(activityAssignmentsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activityAssignmentsProvider),
        child: assignments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune affectation.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final a = list[i];
                return ListTile(
                  title: Text('${a.userName} → ${a.activityName}', style: TextStyle(color: a.active ? null : Colors.grey)),
                  subtitle: Text('${formatDateDisplay(a.startDate)}${a.endDate != null ? ' → ${formatDateDisplay(a.endDate!)}' : ' → en cours'}'),
                  trailing: IconButton(
                    icon: Icon(a.active ? Icons.toggle_on : Icons.toggle_off, color: a.active ? Colors.green : Colors.grey, size: 32),
                    onPressed: () async {
                      await ref.read(billableActivityApiProvider).toggleAssignment(a.id);
                      ref.invalidate(activityAssignmentsProvider);
                    },
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

class _NewAssignmentDialog extends ConsumerStatefulWidget {
  const _NewAssignmentDialog();

  @override
  ConsumerState<_NewAssignmentDialog> createState() => _NewAssignmentDialogState();
}

class _NewAssignmentDialogState extends ConsumerState<_NewAssignmentDialog> {
  BillableActivity? _activity;
  EmployeeSummary? _employee;
  DateTime _startDate = DateTime.now();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(billableActivitiesProvider);
    final employees = ref.watch(allActiveEmployeesProvider);

    return AlertDialog(
      title: const Text('Nouvelle affectation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            activities.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => DropdownButtonFormField<BillableActivity>(
                value: _activity,
                decoration: const InputDecoration(labelText: 'Activité'),
                items: list.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                onChanged: (v) => setState(() => _activity = v),
              ),
            ),
            const SizedBox(height: 12),
            employees.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => DropdownButtonFormField<EmployeeSummary>(
                value: _employee,
                decoration: const InputDecoration(labelText: 'Collaborateur'),
                items: list.map((e) => DropdownMenuItem(value: e, child: Text(e.fullName))).toList(),
                onChanged: (v) => setState(() => _employee = v),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de début'),
              subtitle: Text(formatDateDisplay(_startDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: _submitting || _activity == null || _employee == null
              ? null
              : () async {
                  setState(() => _submitting = true);
                  await ref.read(billableActivityApiProvider).assign(
                        activityId: _activity!.id,
                        userId: _employee!.id,
                        startDate: _startDate,
                      );
                  if (context.mounted) Navigator.pop(context, true);
                },
          child: const Text('Affecter'),
        ),
      ],
    );
  }
}
