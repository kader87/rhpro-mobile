import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'prospect_api.dart';
import 'prospect_models.dart';

final prospectApiProvider = Provider((ref) => ProspectApi(ref.watch(dioProvider)));

final prospectsProvider = FutureProvider.autoDispose<List<Prospect>>((ref) => ref.watch(prospectApiProvider).all());

final devisForProspectProvider = FutureProvider.autoDispose.family<List<Devis>, String>(
  (ref, prospectId) => ref.watch(prospectApiProvider).devisForProspect(prospectId),
);
