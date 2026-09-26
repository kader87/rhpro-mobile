import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'hr_admin_models.dart';
import 'hr_admin_providers.dart';

class HrAdminPage extends ConsumerWidget {
  const HrAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration RH'),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Exporter les congés en CSV',
              onPressed: () => showDialog(context: context, builder: (_) => const _ExportCsvDialog()),
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Jours fériés'), Tab(text: 'Politique de congés'), Tab(text: 'Départements')]),
        ),
        body: const TabBarView(children: [_HolidaysTab(), _LeavePolicyTab(), _DepartmentsTab()]),
      ),
    );
  }
}

class _ExportCsvDialog extends ConsumerStatefulWidget {
  const _ExportCsvDialog();

  @override
  ConsumerState<_ExportCsvDialog> createState() => _ExportCsvDialogState();
}

class _ExportCsvDialogState extends ConsumerState<_ExportCsvDialog> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exporter les congés'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _month,
              decoration: const InputDecoration(labelText: 'Mois'),
              items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
              onChanged: (v) => setState(() => _month = v!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: '$_year',
              decoration: const InputDecoration(labelText: 'Année'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _year = int.tryParse(v) ?? _year,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: _exporting
              ? null
              : () async {
                  setState(() => _exporting = true);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final path = await ref.read(hrAdminApiProvider).exportLeavesToCsv(month: _month, year: _year);
                    if (context.mounted) Navigator.pop(context);
                    messenger.showSnackBar(SnackBar(content: Text('Exporté : $path')));
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('Erreur : $e')));
                    setState(() => _exporting = false);
                  }
                },
          child: const Text('Exporter'),
        ),
      ],
    );
  }
}

class _HolidaysTab extends ConsumerWidget {
  const _HolidaysTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidays = ref.watch(holidaysProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewHolidayDialog());
          if (created == true) ref.invalidate(holidaysProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(holidaysProvider),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Initialiser les jours fériés de l\'année en cours'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(hrAdminApiProvider).initializeYear(DateTime.now().year);
                messenger.showSnackBar(const SnackBar(content: Text('Jours fériés initialisés.')));
                ref.invalidate(holidaysProvider);
              },
            ),
            const Divider(height: 1),
            holidays.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (list) => Column(
                children: list
                    .map((h) => ListTile(
                          title: Text(h.label),
                          subtitle: Text(formatDateDisplay(h.date)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref.read(hrAdminApiProvider).deleteHoliday(h.id);
                              ref.invalidate(holidaysProvider);
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewHolidayDialog extends ConsumerStatefulWidget {
  const _NewHolidayDialog();

  @override
  ConsumerState<_NewHolidayDialog> createState() => _NewHolidayDialogState();
}

class _NewHolidayDialogState extends ConsumerState<_NewHolidayDialog> {
  final _label = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau jour férié'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _label, decoration: const InputDecoration(labelText: 'Libellé *')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(formatDateDisplay(_date)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(DateTime.now().year - 1),
                lastDate: DateTime(DateTime.now().year + 2),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_label.text.trim().isEmpty) return;
            await ref.read(hrAdminApiProvider).createHoliday(date: _date, label: _label.text.trim());
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}

class _LeavePolicyTab extends ConsumerStatefulWidget {
  const _LeavePolicyTab();

  @override
  ConsumerState<_LeavePolicyTab> createState() => _LeavePolicyTabState();
}

class _LeavePolicyTabState extends ConsumerState<_LeavePolicyTab> {
  late TextEditingController _paidLeave;
  late TextEditingController _rtt;
  bool _initialized = false;
  bool _saving = false;

  void _init(LeavePolicy policy) {
    if (_initialized) return;
    _paidLeave = TextEditingController(text: policy.annualPaidLeave.toString());
    _rtt = TextEditingController(text: policy.annualRtt.toString());
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(leavePolicyProvider);

    return policy.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (p) {
        _init(p);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _paidLeave,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Congés payés annuels (jours)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rtt,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'RTT annuels (jours)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      final updated = LeavePolicy(
                        annualPaidLeave: double.tryParse(_paidLeave.text) ?? p.annualPaidLeave,
                        annualRtt: double.tryParse(_rtt.text) ?? p.annualRtt,
                        maxCarryOverDays: p.maxCarryOverDays,
                        renewalMonth: p.renewalMonth,
                        renewalDay: p.renewalDay,
                        enableProrata: p.enableProrata,
                        enableCarryOver: p.enableCarryOver,
                      );
                      await ref.read(hrAdminApiProvider).updateLeavePolicy(updated);
                      ref.invalidate(leavePolicyProvider);
                      setState(() => _saving = false);
                    },
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}

class _DepartmentsTab extends ConsumerWidget {
  const _DepartmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewDepartmentDialog());
          if (created == true) ref.invalidate(departmentsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(departmentsProvider),
        child: departments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final d = list[i];
              return ListTile(
                title: Text(d.name),
                subtitle: Text('${d.employeeCount ?? 0} collaborateur(s)${d.managerName != null ? ' · ${d.managerName}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref.read(hrAdminApiProvider).deleteDepartment(d.id);
                    ref.invalidate(departmentsProvider);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewDepartmentDialog extends ConsumerStatefulWidget {
  const _NewDepartmentDialog();

  @override
  ConsumerState<_NewDepartmentDialog> createState() => _NewDepartmentDialogState();
}

class _NewDepartmentDialogState extends ConsumerState<_NewDepartmentDialog> {
  final _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau département'),
      content: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom *')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_name.text.trim().isEmpty) return;
            await ref.read(hrAdminApiProvider).createDepartment(name: _name.text.trim());
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
