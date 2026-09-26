import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import '../auth/auth_providers.dart';
import 'talent_models.dart';
import 'talent_providers.dart';

const _managerRoles = {'MANAGER', 'ADMIN', 'SUPER_ADMIN'};

class TrainingsPage extends ConsumerWidget {
  const TrainingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainings = ref.watch(trainingsProvider);
    final myEnrollments = ref.watch(myEnrollmentsProvider);
    final isManager = _managerRoles.contains(ref.watch(authControllerProvider).value?.role);

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      floatingActionButton: isManager
          ? FloatingActionButton(
              onPressed: () async {
                final created = await showDialog<bool>(context: context, builder: (_) => const _NewTrainingDialog());
                if (created == true) ref.invalidate(trainingsProvider);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trainingsProvider);
          ref.invalidate(myEnrollmentsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Mes inscriptions', style: Theme.of(context).textTheme.titleMedium),
            myEnrollments.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => list.isEmpty
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Aucune inscription.'))
                  : Column(
                      children: list
                          .map((e) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(e.trainingTitle),
                                subtitle: Text('${formatDateDisplay(e.enrollmentDate)} · ${e.status.label}'),
                              ))
                          .toList(),
                    ),
            ),
            const Divider(height: 32),
            Text('Catalogue', style: Theme.of(context).textTheme.titleMedium),
            trainings.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => Column(
                children: list
                    .map((t) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.title),
                          subtitle: Text([if (t.provider != null) t.provider!, if (t.durationHours != null) '${t.durationHours}h'].join(' · ')),
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

class _NewTrainingDialog extends ConsumerStatefulWidget {
  const _NewTrainingDialog();

  @override
  ConsumerState<_NewTrainingDialog> createState() => _NewTrainingDialogState();
}

class _NewTrainingDialogState extends ConsumerState<_NewTrainingDialog> {
  final _title = TextEditingController();
  final _provider = TextEditingController();
  final _duration = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle formation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titre *')),
          TextField(controller: _provider, decoration: const InputDecoration(labelText: 'Organisme')),
          TextField(controller: _duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Durée (h)')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_title.text.trim().isEmpty) return;
            await ref.read(talentApiProvider).createTraining(
                  title: _title.text.trim(),
                  provider: _provider.text.trim().isEmpty ? null : _provider.text.trim(),
                  durationHours: int.tryParse(_duration.text),
                );
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
