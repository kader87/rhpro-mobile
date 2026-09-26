import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'absence_models.dart';
import 'absence_providers.dart';
import 'new_absence_page.dart';

class AbsencesPage extends ConsumerWidget {
  const AbsencesPage({super.key});

  Color _statusColor(AbsenceStatus status) => switch (status) {
        AbsenceStatus.pending => Colors.orange,
        AbsenceStatus.approved => Colors.green,
        AbsenceStatus.rejected => Colors.red,
        AbsenceStatus.canceled => Colors.grey,
      };

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myAbsencesProvider);
    ref.invalidate(myLeaveBalanceProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final absences = ref.watch(myAbsencesProvider);
    final balance = ref.watch(myLeaveBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes absences')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewAbsencePage()),
          );
          if (created == true) await _refresh(ref);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            balance.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Solde indisponible : $e'),
              data: (b) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BalanceTile(label: 'CP', value: b.paidLeaveBalance, total: b.paidLeaveTotal),
                      _BalanceTile(label: 'RTT', value: b.rttBalance, total: b.rttTotal),
                      _BalanceTile(label: 'Récup.', value: b.compensatoryLeaveBalance, total: b.compensatoryLeaveTotal),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            absences.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Erreur : $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune demande d\'absence.')));
                }
                return Column(
                  children: list
                      .map((a) => Card(
                            child: ListTile(
                              title: Text(a.type.label),
                              subtitle: Text('${formatDateDisplay(a.startDate)} → ${formatDateDisplay(a.endDate)}'
                                  '${a.workingDays != null ? ' · ${a.workingDays} j' : ''}'),
                              trailing: Chip(
                                label: Text(a.status.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                backgroundColor: _statusColor(a.status),
                              ),
                              onTap: a.status == AbsenceStatus.pending
                                  ? () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Annuler la demande ?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui, annuler')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ref.read(absenceApiProvider).cancel(a.id);
                                        await _refresh(ref);
                                      }
                                    }
                                  : null,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.label, required this.value, required this.total});

  final String label;
  final double value;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall),
        Text('/ ${total.toStringAsFixed(0)} $label', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
