import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'superadmin_providers.dart';

class PromoCodesPage extends ConsumerWidget {
  const PromoCodesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codes = ref.watch(promoCodesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Codes promo')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewPromoCodeDialog());
          if (created == true) ref.invalidate(promoCodesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(promoCodesProvider),
        child: codes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun code promo.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return ListTile(
                  title: Text(c.code, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  subtitle: Text('${c.discountAmount.toStringAsFixed(2)} € · ${c.used ? 'Utilisé' : 'Disponible'}'),
                  trailing: c.used ? const Icon(Icons.check, color: Colors.grey) : const Icon(Icons.local_offer, color: Colors.green),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NewPromoCodeDialog extends ConsumerStatefulWidget {
  const _NewPromoCodeDialog();

  @override
  ConsumerState<_NewPromoCodeDialog> createState() => _NewPromoCodeDialogState();
}

class _NewPromoCodeDialogState extends ConsumerState<_NewPromoCodeDialog> {
  final _amount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau code promo'),
      content: TextField(
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Montant de la remise (€) *'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            final euros = double.tryParse(_amount.text.replaceAll(',', '.'));
            if (euros == null || euros <= 0) return;
            await ref.read(superAdminApiProvider).createPromoCode(discountAmountCents: (euros * 100).round());
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Générer'),
        ),
      ],
    );
  }
}
