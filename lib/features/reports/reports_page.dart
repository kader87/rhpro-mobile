import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../absences/absence_models.dart';
import 'reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(teamAbsencesReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rapports · Absences équipe')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(teamAbsencesReportProvider),
        child: report.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            final total = list.length;
            final approved = list.where((a) => a.status == AbsenceStatus.approved).length;
            final pending = list.where((a) => a.status == AbsenceStatus.pending).length;
            final rejected = list.where((a) => a.status == AbsenceStatus.rejected).length;

            final byType = <AbsenceType, int>{};
            for (final a in list) {
              byType[a.type] = (byType[a.type] ?? 0) + 1;
            }
            final sortedTypes = byType.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _KpiTile(label: 'Total', value: total, color: Colors.blueGrey),
                    _KpiTile(label: 'Approuvées', value: approved, color: Colors.green),
                    _KpiTile(label: 'En attente', value: pending, color: Colors.orange),
                    _KpiTile(label: 'Refusées', value: rejected, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Répartition par type', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (sortedTypes.isEmpty) const Text('Aucune donnée.'),
                ...sortedTypes.map((e) => ListTile(
                      title: Text(e.key.label),
                      trailing: Text('${e.value}', style: Theme.of(context).textTheme.titleMedium),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('$value', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
              Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
