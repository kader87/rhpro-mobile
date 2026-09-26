import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import '../team/employee_models.dart';
import '../team/employee_providers.dart';
import 'equipment_models.dart';
import 'equipment_providers.dart';

class EquipmentAdminPage extends StatelessWidget {
  const EquipmentAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Équipements'),
          bottom: const TabBar(tabs: [Tab(text: 'Catalogue'), Tab(text: 'Achats'), Tab(text: 'Affectations')]),
        ),
        body: const TabBarView(children: [_ItemsTab(), _PurchasesTab(), _AssignmentsTab()]),
      ),
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  const _ItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(equipmentItemsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewItemDialog());
          if (created == true) ref.invalidate(equipmentItemsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(equipmentItemsProvider),
        child: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              return ListTile(
                title: Text(item.name, style: TextStyle(color: item.active ? null : Colors.grey)),
                subtitle: Text('Stock : ${item.availableStock}/${item.totalStock} disponible'
                    '${item.isLowStock ? ' · seuil bas' : ''}'),
                leading: Icon(Icons.inventory_2_outlined, color: item.isLowStock ? Colors.orange : null),
                trailing: IconButton(
                  icon: Icon(item.active ? Icons.toggle_on : Icons.toggle_off, color: item.active ? Colors.green : Colors.grey, size: 32),
                  onPressed: () async {
                    await ref.read(equipmentApiProvider).toggleItemActive(item.id);
                    ref.invalidate(equipmentItemsProvider);
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

class _NewItemDialog extends ConsumerStatefulWidget {
  const _NewItemDialog();

  @override
  ConsumerState<_NewItemDialog> createState() => _NewItemDialogState();
}

class _NewItemDialogState extends ConsumerState<_NewItemDialog> {
  final _name = TextEditingController();
  final _threshold = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel article'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom *')),
          TextField(controller: _threshold, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seuil d\'alerte')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_name.text.trim().isEmpty) return;
            await ref.read(equipmentApiProvider).createItem(
                  name: _name.text.trim(),
                  alertThreshold: int.tryParse(_threshold.text) ?? 5,
                );
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}

class _PurchasesTab extends ConsumerWidget {
  const _PurchasesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(equipmentPurchasesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewPurchaseDialog());
          if (created == true) ref.invalidate(equipmentPurchasesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(equipmentPurchasesProvider),
        child: purchases.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              return ListTile(
                title: Text('${p.itemName} × ${p.quantity}'),
                subtitle: Text('${formatDateDisplay(p.purchaseDate)} · ${p.totalAmount.toStringAsFixed(2)} €'),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewPurchaseDialog extends ConsumerStatefulWidget {
  const _NewPurchaseDialog();

  @override
  ConsumerState<_NewPurchaseDialog> createState() => _NewPurchaseDialogState();
}

class _NewPurchaseDialogState extends ConsumerState<_NewPurchaseDialog> {
  EquipmentItem? _item;
  final _quantity = TextEditingController(text: '1');
  final _unitPrice = TextEditingController();
  final DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(equipmentItemsProvider);

    return AlertDialog(
      title: const Text('Nouvel achat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            items.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => DropdownButtonFormField<EquipmentItem>(
                value: _item,
                decoration: const InputDecoration(labelText: 'Article'),
                items: list.map((it) => DropdownMenuItem(value: it, child: Text(it.name))).toList(),
                onChanged: (v) => setState(() => _item = v),
              ),
            ),
            TextField(controller: _quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité')),
            TextField(
              controller: _unitPrice,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Prix unitaire'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_item == null) return;
            await ref.read(equipmentApiProvider).createPurchase(
                  itemId: _item!.id,
                  quantity: int.tryParse(_quantity.text) ?? 1,
                  unitPrice: double.tryParse(_unitPrice.text.replaceAll(',', '.')) ?? 0,
                  purchaseDate: _date,
                );
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _AssignmentsTab extends ConsumerWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(allEquipmentAssignmentsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewAssignmentDialog());
          if (created == true) ref.invalidate(allEquipmentAssignmentsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allEquipmentAssignmentsProvider),
        child: assignments.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final a = list[i];
              return ListTile(
                title: Text('${a.employeeName} · ${a.itemName} × ${a.quantity}'),
                subtitle: Text(a.isActive ? 'Depuis le ${formatDateDisplay(a.assignmentDate)}' : 'Restitué'),
                trailing: a.isActive
                    ? IconButton(
                        icon: const Icon(Icons.assignment_return),
                        tooltip: 'Restituer',
                        onPressed: () async {
                          await ref.read(equipmentApiProvider).returnAssignment(a.id);
                          ref.invalidate(allEquipmentAssignmentsProvider);
                        },
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewAssignmentDialog extends ConsumerStatefulWidget {
  const _NewAssignmentDialog();

  @override
  ConsumerState<_NewAssignmentDialog> createState() => _NewAssignmentDialogState();
}

class _NewAssignmentDialogState extends ConsumerState<_NewAssignmentDialog> {
  EquipmentItem? _item;
  EmployeeSummary? _employee;
  final _quantity = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(equipmentItemsProvider);
    final employees = ref.watch(allActiveEmployeesProvider);

    return AlertDialog(
      title: const Text('Nouvelle affectation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            items.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => DropdownButtonFormField<EquipmentItem>(
                value: _item,
                decoration: const InputDecoration(labelText: 'Article'),
                items: list.map((it) => DropdownMenuItem(value: it, child: Text('${it.name} (${it.availableStock} dispo.)'))).toList(),
                onChanged: (v) => setState(() => _item = v),
              ),
            ),
            employees.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur : $e'),
              data: (list) => DropdownButtonFormField<EmployeeSummary>(
                value: _employee,
                decoration: const InputDecoration(labelText: 'Collaborateur'),
                items: list.map((e) => DropdownMenuItem(value: e, child: Text(e.fullName))).toList(),
                onChanged: (v) => setState(() => _employee = v),
              ),
            ),
            TextField(controller: _quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_item == null || _employee == null) return;
            await ref.read(equipmentApiProvider).assign(
                  itemId: _item!.id,
                  employeeId: _employee!.id,
                  quantity: int.tryParse(_quantity.text) ?? 1,
                  assignmentDate: DateTime.now(),
                );
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Affecter'),
        ),
      ],
    );
  }
}
