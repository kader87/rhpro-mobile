import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'equipment_providers.dart';

class MyEquipmentPage extends ConsumerWidget {
  const MyEquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(myEquipmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon matériel')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myEquipmentProvider),
        child: assignments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun matériel affecté.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final a = list[i];
                return ListTile(
                  leading: const Icon(Icons.devices_other),
                  title: Text('${a.itemName} × ${a.quantity}'),
                  subtitle: Text(a.isActive
                      ? 'Depuis le ${formatDateDisplay(a.assignmentDate)}'
                      : 'Restitué le ${a.returnDate != null ? formatDateDisplay(a.returnDate!) : ''}'),
                  trailing: a.isActive ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.history, color: Colors.grey),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
