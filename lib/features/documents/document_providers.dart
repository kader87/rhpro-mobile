import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'document_api.dart';
import 'document_models.dart';

final documentApiProvider = Provider((ref) => DocumentApi(ref.watch(dioProvider)));

final myDocumentsProvider = FutureProvider.autoDispose<List<RhDocument>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  return ref.watch(documentApiProvider).forOwner(user.id);
});
