import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'client_api.dart';
import 'client_models.dart';

final clientApiProvider = Provider((ref) => ClientApi(ref.watch(dioProvider)));

final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) => ref.watch(clientApiProvider).all());
