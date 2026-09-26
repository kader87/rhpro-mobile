import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import 'timesheet_models.dart';
import 'timesheet_providers.dart';
import 'new_timesheet_entry_page.dart';

class TimesheetsPage extends ConsumerWidget {
  const TimesheetsPage({super.key});

  Color _statusColor(TimesheetStatus status) => switch (status) {
        TimesheetStatus.draft => Colors.grey,
        TimesheetStatus.submitted => Colors.orange,
        TimesheetStatus.approved => Colors.green,
        TimesheetStatus.rejected => Colors.red,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(currentMonthTimesheetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes feuilles de temps')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewTimesheetEntryPage()),
          );
          if (added == true) ref.invalidate(currentMonthTimesheetProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(currentMonthTimesheetProvider),
        child: entries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune saisie ce mois-ci.')))],
              );
            }
            final sorted = [...list]..sort((a, b) => b.entryDate.compareTo(a.entryDate));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final e = sorted[i];
                return Card(
                  child: ListTile(
                    title: Text(e.activityName),
                    subtitle: Text('${formatDateDisplay(e.entryDate)} · ${e.amount} ${e.unit.label}'),
                    trailing: Chip(
                      label: Text(e.status.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: _statusColor(e.status),
                    ),
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
