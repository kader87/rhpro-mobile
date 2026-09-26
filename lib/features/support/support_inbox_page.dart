import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support_models.dart';
import 'support_providers.dart';

class SupportInboxPage extends ConsumerWidget {
  const SupportInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(supportInboxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messagerie support')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(supportInboxProvider),
        child: messages.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Boîte vide.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final m = list[i];
                return ExpansionTile(
                  title: Text('${m.subject} · ${m.senderName ?? ''}'),
                  subtitle: Text(m.status.label),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.message),
                          const SizedBox(height: 12),
                          if (m.status != SupportMessageStatus.closed)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => showDialog(context: context, builder: (_) => _ReplyDialog(messageId: m.id)),
                                    child: const Text('Répondre'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () async {
                                    await ref.read(supportApiProvider).close(m.id);
                                    ref.invalidate(supportInboxProvider);
                                  },
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReplyDialog extends ConsumerStatefulWidget {
  const _ReplyDialog({required this.messageId});

  final String messageId;

  @override
  ConsumerState<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends ConsumerState<_ReplyDialog> {
  final _reply = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Répondre'),
      content: TextField(controller: _reply, decoration: const InputDecoration(labelText: 'Réponse'), maxLines: 4),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_reply.text.trim().isEmpty) return;
            await ref.read(supportApiProvider).reply(widget.messageId, _reply.text.trim());
            ref.invalidate(supportInboxProvider);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}
