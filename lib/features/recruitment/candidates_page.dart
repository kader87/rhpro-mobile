import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'candidate_models.dart';
import 'candidate_providers.dart';

class CandidatesPage extends ConsumerWidget {
  const CandidatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(candidatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recrutement')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewCandidateDialog());
          if (created == true) ref.invalidate(candidatesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(candidatesProvider),
        child: candidates.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun candidat.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return ListTile(
                  title: Text(c.fullName),
                  subtitle: Text(c.position),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<CandidateStatus>(
                        value: c.status,
                        underline: const SizedBox(),
                        items: CandidateStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                        onChanged: (s) async {
                          if (s == null) return;
                          await ref.read(candidateApiProvider).updateStatus(c.id, s);
                          ref.invalidate(candidatesProvider);
                        },
                      ),
                      if (c.status == CandidateStatus.hired)
                        IconButton(
                          icon: const Icon(Icons.person_add_alt_1),
                          tooltip: 'Convertir en employé',
                          onPressed: () => showDialog(context: context, builder: (_) => _ConvertDialog(candidate: c)),
                        ),
                    ],
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

class _NewCandidateDialog extends ConsumerStatefulWidget {
  const _NewCandidateDialog();

  @override
  ConsumerState<_NewCandidateDialog> createState() => _NewCandidateDialogState();
}

class _NewCandidateDialogState extends ConsumerState<_NewCandidateDialog> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _position = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau candidat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Prénom *')),
            TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Nom *')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email *')),
            TextField(controller: _position, decoration: const InputDecoration(labelText: 'Poste *')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if ([_firstName, _lastName, _email, _position].any((c) => c.text.trim().isEmpty)) return;
            await ref.read(candidateApiProvider).create(
                  firstName: _firstName.text.trim(),
                  lastName: _lastName.text.trim(),
                  email: _email.text.trim(),
                  position: _position.text.trim(),
                );
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}

class _ConvertDialog extends ConsumerStatefulWidget {
  const _ConvertDialog({required this.candidate});

  final Candidate candidate;

  @override
  ConsumerState<_ConvertDialog> createState() => _ConvertDialogState();
}

class _ConvertDialogState extends ConsumerState<_ConvertDialog> {
  final _employeeId = TextEditingController();
  final _department = TextEditingController();
  DateTime _dateOfJoining = DateTime.now();
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Convertir ${widget.candidate.fullName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _employeeId, decoration: const InputDecoration(labelText: 'Matricule *')),
            TextField(controller: _department, decoration: const InputDecoration(labelText: 'Département *')),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date d\'entrée'),
              subtitle: Text(formatDateDisplay(_dateOfJoining)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dateOfJoining,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dateOfJoining = picked);
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
                  if (_employeeId.text.trim().isEmpty || _department.text.trim().isEmpty) {
                    setState(() => _error = 'Matricule et département obligatoires.');
                    return;
                  }
                  setState(() => _submitting = true);
                  try {
                    await ref.read(candidateApiProvider).convertToEmployee(
                          widget.candidate.id,
                          employeeId: _employeeId.text.trim(),
                          department: _department.text.trim(),
                          dateOfJoining: formatDateIso(_dateOfJoining),
                        );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    setState(() {
                      _error = 'Erreur : $e';
                      _submitting = false;
                    });
                  }
                },
          child: const Text('Convertir'),
        ),
      ],
    );
  }
}
