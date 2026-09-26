import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import '../absences/absence_models.dart';
import 'approval_providers.dart';

Future<String?> _askReason(BuildContext context, String title) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Motif'),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );
}

class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approbations'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Absences'),
            Tab(text: 'Annulations'),
            Tab(text: 'CRA'),
          ]),
        ),
        body: const TabBarView(
          children: [_AbsenceApprovalsTab(), _CancellationApprovalsTab(), _TimesheetApprovalsTab()],
        ),
      ),
    );
  }
}

class _AbsenceApprovalsTab extends ConsumerWidget {
  const _AbsenceApprovalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingAbsencesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingAbsencesProvider),
      child: pending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune demande en attente.')))]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final a = list[i];
              return Card(
                child: ListTile(
                  title: Text('${a.employee.fullName} · ${a.type.label}'),
                  subtitle: Text('${formatDateDisplay(a.startDate)} → ${formatDateDisplay(a.endDate)}'
                      '${a.reason != null ? '\n${a.reason}' : ''}'),
                  isThreeLine: a.reason != null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          await ref.read(approvalApiProvider).approveAbsence(a.id);
                          ref.invalidate(pendingAbsencesProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          final reason = await _askReason(context, 'Refuser la demande');
                          if (reason == null || reason.isEmpty) return;
                          await ref.read(approvalApiProvider).rejectAbsence(a.id, reason);
                          ref.invalidate(pendingAbsencesProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CancellationApprovalsTab extends ConsumerWidget {
  const _CancellationApprovalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCancellationsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingCancellationsProvider),
      child: pending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune annulation en attente.')))]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final a = list[i];
              return Card(
                child: ListTile(
                  title: Text('${a.employee.fullName} · ${a.type.label}'),
                  subtitle: Text('${formatDateDisplay(a.startDate)} → ${formatDateDisplay(a.endDate)} (déjà approuvée)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Confirmer l\'annulation',
                        onPressed: () async {
                          await ref.read(approvalApiProvider).approveCancellation(a.id);
                          ref.invalidate(pendingCancellationsProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Garder l\'absence',
                        onPressed: () async {
                          await ref.read(approvalApiProvider).rejectCancellation(a.id);
                          ref.invalidate(pendingCancellationsProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TimesheetApprovalsTab extends ConsumerWidget {
  const _TimesheetApprovalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingTimesheetsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingTimesheetsProvider),
      child: pending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune saisie en attente.')))]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              return Card(
                child: ListTile(
                  title: Text('${t.employeeName ?? ''} · ${t.activityName}'),
                  subtitle: Text('${formatDateDisplay(t.entryDate)} · ${t.amount} ${t.unit.label}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          await ref.read(approvalApiProvider).approveTimesheetEntry(t);
                          ref.invalidate(pendingTimesheetsProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          final reason = await _askReason(context, 'Rejeter la saisie');
                          if (reason == null || reason.isEmpty) return;
                          await ref.read(approvalApiProvider).rejectTimesheetEntry(t, reason);
                          ref.invalidate(pendingTimesheetsProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
