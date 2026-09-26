import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'finance_models.dart';
import 'finance_providers.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(authControllerProvider).value?.role == 'ADMIN';

    return DefaultTabController(
      length: isAdmin ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Facturation'),
          bottom: TabBar(tabs: [
            const Tab(text: 'À facturer'),
            const Tab(text: 'Factures'),
            if (isAdmin) const Tab(text: 'Rentabilité'),
          ]),
        ),
        body: TabBarView(children: [
          const _InvoicableTab(),
          const _InvoicesTab(),
          if (isAdmin) const _ProfitabilityTab(),
        ]),
      ),
    );
  }
}

class _InvoicableTab extends ConsumerWidget {
  const _InvoicableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(invoicableEntriesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(invoicableEntriesProvider),
      child: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Rien à facturer.')))]);
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];
              return ListTile(
                title: Text(e.note),
                subtitle: Text('${e.activityName} · ${e.amount}'),
                trailing: FilledButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final invoice = await ref.read(financeApiProvider).generateInvoice(e.entryIds);
                    messenger.showSnackBar(SnackBar(content: Text('Facture ${invoice.invoiceNumber} générée.')));
                    ref.invalidate(invoicableEntriesProvider);
                    ref.invalidate(invoicesProvider);
                  },
                  child: const Text('Facturer'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(invoicesProvider),
      child: invoices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune facture.')))]);
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final inv = list[i];
              return ListTile(
                title: Text(inv.invoiceNumber),
                subtitle: Text('${inv.status.label} · ${inv.totalAmountInclTax.toStringAsFixed(2)} € TTC'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfitabilityTab extends ConsumerWidget {
  const _ProfitabilityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(profitabilityProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(profitabilityProvider),
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final p = list[i];
            return ListTile(
              title: Text(p.employeeName),
              subtitle: Text('CA : ${p.totalBilled.toStringAsFixed(0)} € · Coût : ${p.totalCost.toStringAsFixed(0)} €'),
              trailing: Text('${p.profitMargin.toStringAsFixed(0)} %',
                  style: TextStyle(color: p.grossProfit >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }
}

