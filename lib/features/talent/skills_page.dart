import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'talent_models.dart';
import 'talent_providers.dart';

const _managerRoles = {'MANAGER', 'ADMIN', 'SUPER_ADMIN'};

class SkillsPage extends ConsumerWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);
    final mySkills = ref.watch(mySkillsProvider);
    final isManager = _managerRoles.contains(ref.watch(authControllerProvider).value?.role);

    return Scaffold(
      appBar: AppBar(title: const Text('Compétences')),
      floatingActionButton: isManager
          ? FloatingActionButton(
              onPressed: () async {
                final created = await showDialog<bool>(context: context, builder: (_) => const _NewSkillDialog());
                if (created == true) ref.invalidate(skillsProvider);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(skillsProvider);
          ref.invalidate(mySkillsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Mes compétences', style: Theme.of(context).textTheme.titleMedium),
            mySkills.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => list.isEmpty
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Aucune compétence renseignée.'))
                  : Wrap(
                      spacing: 8,
                      children: list.map((s) => Chip(label: Text('${s.skillName} · ${s.level.label}'))).toList(),
                    ),
            ),
            const Divider(height: 32),
            Text('Référentiel', style: Theme.of(context).textTheme.titleMedium),
            skills.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => Column(
                children: list
                    .map((s) => ListTile(contentPadding: EdgeInsets.zero, title: Text(s.name), subtitle: s.category != null ? Text(s.category!) : null))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewSkillDialog extends ConsumerStatefulWidget {
  const _NewSkillDialog();

  @override
  ConsumerState<_NewSkillDialog> createState() => _NewSkillDialogState();
}

class _NewSkillDialogState extends ConsumerState<_NewSkillDialog> {
  final _name = TextEditingController();
  final _category = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle compétence'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom *')),
          TextField(controller: _category, decoration: const InputDecoration(labelText: 'Catégorie')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_name.text.trim().isEmpty) return;
            await ref.read(talentApiProvider).createSkill(name: _name.text.trim(), category: _category.text.trim().isEmpty ? null : _category.text.trim());
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
