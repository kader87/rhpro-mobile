import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support_models.dart';
import 'support_providers.dart';

class SupportPage extends ConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(myMessagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<bool>(context: context, builder: (_) => const _NewTicketDialog());
          if (created == true) ref.invalidate(myMessagesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myMessagesProvider),
        child: messages.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun message.')))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final m = list[i];
                return ExpansionTile(
                  title: Text(m.subject),
                  subtitle: Text(m.status.label),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.message),
                          if (m.reply != null) ...[
                            const Divider(),
                            Text('Réponse :', style: Theme.of(context).textTheme.labelMedium),
                            Text(m.reply!),
                          ],
                          if (m.status == SupportMessageStatus.answered)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () async {
                                  await ref.read(supportApiProvider).acknowledge(m.id);
                                  ref.invalidate(myMessagesProvider);
                                },
                                child: const Text('Marquer comme traité'),
                              ),
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

class _NewTicketDialog extends ConsumerStatefulWidget {
  const _NewTicketDialog();

  @override
  ConsumerState<_NewTicketDialog> createState() => _NewTicketDialogState();
}

class _NewTicketDialogState extends ConsumerState<_NewTicketDialog> {
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Contacter le support'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Sujet *')),
          TextField(controller: _message, decoration: const InputDecoration(labelText: 'Message *'), maxLines: 4),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) return;
            await ref.read(supportApiProvider).createTicket(subject: _subject.text.trim(), message: _message.text.trim());
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}
