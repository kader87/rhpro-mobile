import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/timesheet_unit.dart';
import 'activity_edit_page.dart';
import 'activity_providers.dart';

class ActivitiesPage extends ConsumerWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(billableActivitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activités')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const ActivityEditPage()),
          );
          if (saved == true) ref.invalidate(billableActivitiesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(billableActivitiesProvider),
        child: activities.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune activité.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final a = list[i];
                return ListTile(
                  title: Text(a.name, style: TextStyle(color: a.active ? null : Colors.grey)),
                  subtitle: Text([
                    if (a.client != null) a.client!.name,
                    if (a.price != null) '${a.price} € / ${a.pricingUnit.label}',
                  ].join(' · ')),
                  trailing: IconButton(
                    icon: Icon(a.active ? Icons.toggle_on : Icons.toggle_off, color: a.active ? Colors.green : Colors.grey, size: 32),
                    onPressed: () async {
                      await ref.read(billableActivityApiProvider).toggleActive(a.id);
                      ref.invalidate(billableActivitiesProvider);
                    },
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
