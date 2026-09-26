import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import '../auth/auth_providers.dart';
import '../team/employee_models.dart';
import '../team/employee_providers.dart';
import 'talent_models.dart';
import 'talent_providers.dart';

const _managerRoles = {'MANAGER', 'ADMIN', 'SUPER_ADMIN'};
const _interviewTypes = [
  'ANNUAL',
  'PROFESSIONAL_CAREER',
  'PROBATION',
  'RETURN_ABSENCE',
  'MANAGEMENT_FOLLOWUP',
  'DISCIPLINARY',
  'DEPARTURE',
  'OTHER',
];

class InterviewsPage extends ConsumerWidget {
  const InterviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManager = _managerRoles.contains(ref.watch(authControllerProvider).value?.role);

    return DefaultTabController(
      length: isManager ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entretiens'),
          bottom: TabBar(tabs: [const Tab(text: 'Mes entretiens'), if (isManager) const Tab(text: 'Toute l\'équipe')]),
        ),
        body: TabBarView(children: [
          _InterviewList(provider: myInterviewsProvider, canManage: false),
          if (isManager) _InterviewList(provider: allInterviewsProvider, canManage: true),
        ]),
        floatingActionButton: isManager
            ? Builder(builder: (context) {
                // Only meaningful on the "team" tab, but a single FAB is simplest; scheduling
                // from "my interviews" just lands in the same shared list.
                return FloatingActionButton(
                  onPressed: () async {
                    final created = await showDialog<bool>(context: context, builder: (_) => const _NewInterviewDialog());
                    if (created == true) ref.invalidate(allInterviewsProvider);
                  },
                  child: const Icon(Icons.add),
                );
              })
            : null,
      ),
    );
  }
}

class _InterviewList extends ConsumerWidget {
  const _InterviewList({required this.provider, required this.canManage});

  final AutoDisposeFutureProvider<List<Interview>> provider;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviews = ref.watch(provider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(provider),
      child: interviews.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun entretien.')))]);
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final it = list[i];
              final cancellable = canManage && it.status != InterviewStatus.cancelled && it.status != InterviewStatus.archived;
              return ListTile(
                title: Text('${it.employeeName} · ${it.type}'),
                subtitle: Text('${formatDateDisplay(it.scheduledDate)} avec ${it.interviewerName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(it.status.label, style: const TextStyle(fontSize: 11))),
                    if (cancellable)
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Annuler',
                        onPressed: () async {
                          await ref.read(talentApiProvider).cancelInterview(it.id);
                          ref.invalidate(provider);
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NewInterviewDialog extends ConsumerStatefulWidget {
  const _NewInterviewDialog();

  @override
  ConsumerState<_NewInterviewDialog> createState() => _NewInterviewDialogState();
}

class _NewInterviewDialogState extends ConsumerState<_NewInterviewDialog> {
  EmployeeSummary? _employee;
  EmployeeSummary? _interviewer;
  String _type = _interviewTypes.first;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 7));
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(allActiveEmployeesProvider);

    return AlertDialog(
      title: const Text('Nouvel entretien'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            employees.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => Column(
                children: [
                  DropdownButtonFormField<EmployeeSummary>(
                    value: _employee,
                    decoration: const InputDecoration(labelText: 'Salarié'),
                    items: list.map((e) => DropdownMenuItem(value: e, child: Text(e.fullName))).toList(),
                    onChanged: (v) => setState(() => _employee = v),
                  ),
                  DropdownButtonFormField<EmployeeSummary>(
                    value: _interviewer,
                    decoration: const InputDecoration(labelText: 'Interlocuteur'),
                    items: list.map((e) => DropdownMenuItem(value: e, child: Text(e.fullName))).toList(),
                    onChanged: (v) => setState(() => _interviewer = v),
                  ),
                ],
              ),
            ),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _interviewTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(formatDateDisplay(_scheduledDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _scheduledDate = picked);
              },
            ),
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
                  if (_employee == null || _interviewer == null) {
                    setState(() => _error = 'Salarié et interlocuteur obligatoires.');
                    return;
                  }
                  setState(() => _submitting = true);
                  try {
                    await ref.read(talentApiProvider).createInterview(
                          employeeId: _employee!.id,
                          interviewerId: _interviewer!.id,
                          type: _type,
                          scheduledDate: _scheduledDate,
                        );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    setState(() {
                      _error = 'Erreur : $e';
                      _submitting = false;
                    });
                  }
                },
          child: const Text('Planifier'),
        ),
      ],
    );
  }
}
