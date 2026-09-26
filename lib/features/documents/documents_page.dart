import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'document_models.dart';
import 'document_providers.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(myDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes documents')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myDocumentsProvider),
        child: documents.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Aucun document.')))],
              );
            }
            final byType = <DocumentType, List<RhDocument>>{};
            for (final d in list) {
              byType.putIfAbsent(d.type, () => []).add(d);
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: byType.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(entry.key.label, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ...entry.value.map((d) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(d.name),
                          subtitle: Text('${d.formattedDate} · ${d.formattedSize}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final path = await ref.read(documentApiProvider).download(d);
                                messenger.showSnackBar(SnackBar(content: Text('Téléchargé : $path')));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text('Échec du téléchargement : $e')));
                              }
                            },
                          ),
                        ),
                      )),
                ];
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
