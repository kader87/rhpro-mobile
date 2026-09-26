import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import 'planning_models.dart';
import 'planning_providers.dart';

class PlanningPage extends ConsumerWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planning = ref.watch(myPlanningProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon planning')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myPlanningProvider),
        child: planning.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (shifts) {
            if (shifts.isEmpty) {
              return ListView(
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun planning à venir.')))],
              );
            }
            final sorted = [...shifts]..sort((a, b) => a.startDate.compareTo(b.startDate));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final s = sorted[i];
                return Card(
                  child: ListTile(
                    title: Text(s.activityName),
                    subtitle: Text(
                      [
                        if (s.clientName != null) s.clientName!,
                        '${formatDateDisplay(s.startDate)} → ${formatDateDisplay(s.endDate)}',
                        '${s.dailyAmount} ${s.unit.label}/j',
                      ].join(' · '),
                    ),
                    trailing: s.status == ShiftStatus.cancelled
                        ? const Icon(Icons.cancel, color: Colors.grey)
                        : s.status == ShiftStatus.convertedToCra
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.schedule, color: Colors.blue),
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
