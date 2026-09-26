import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'notification_providers.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  void _refresh(WidgetRef ref) {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: () async {
              await ref.read(notificationApiProvider).markAllAsRead();
              _refresh(ref);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(ref),
        child: notifications.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucune notification.')))],
              );
            }
            final sorted = [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.builder(
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final n = sorted[i];
                return ListTile(
                  leading: Icon(
                    n.read ? Icons.notifications_none : Icons.notifications,
                    color: n.read ? Colors.grey : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    n.message,
                    style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(formatDateDisplay(n.createdAt)),
                  onTap: n.read
                      ? null
                      : () async {
                          await ref.read(notificationApiProvider).markAsRead(n.id);
                          _refresh(ref);
                        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
