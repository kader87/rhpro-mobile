import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'support_api.dart';
import 'support_models.dart';

final supportApiProvider = Provider((ref) => SupportApi(ref.watch(dioProvider)));

final myMessagesProvider = FutureProvider.autoDispose<List<SupportMessage>>((ref) => ref.watch(supportApiProvider).myMessages());

final supportInboxProvider = FutureProvider.autoDispose<List<SupportMessage>>((ref) => ref.watch(supportApiProvider).inbox());
