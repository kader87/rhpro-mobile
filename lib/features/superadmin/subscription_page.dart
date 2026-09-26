import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'superadmin_providers.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Abonnement')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(currentSubscriptionProvider),
        child: subscription.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (s) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statut : ${s.status}', style: Theme.of(context).textTheme.titleMedium),
                      Text('Formule : ${s.tier}'),
                      Text('Licences : ${s.licenseCount}'),
                      if (s.periodEnd != null) Text('Fin de période : ${s.periodEnd}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Renouvellement automatique'),
                value: s.autoRenew,
                onChanged: (v) async {
                  await ref.read(superAdminApiProvider).setAutoRenew(v);
                  ref.invalidate(currentSubscriptionProvider);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Résilier l\'abonnement ?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Résilier')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(superAdminApiProvider).cancelSubscription();
                    ref.invalidate(currentSubscriptionProvider);
                  }
                },
                child: const Text('Résilier l\'abonnement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
