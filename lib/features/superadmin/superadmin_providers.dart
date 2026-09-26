import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'superadmin_api.dart';
import 'superadmin_models.dart';

final superAdminApiProvider = Provider((ref) => SuperAdminApi(ref.watch(dioProvider)));

final currentSubscriptionProvider = FutureProvider.autoDispose<SubscriptionInfo>(
  (ref) => ref.watch(superAdminApiProvider).currentSubscription(),
);

final customerAccountsProvider = FutureProvider.autoDispose<List<CustomerAccount>>(
  (ref) => ref.watch(superAdminApiProvider).customerAccounts(),
);

final promoCodesProvider = FutureProvider.autoDispose<List<PromoCode>>(
  (ref) => ref.watch(superAdminApiProvider).promoCodes(),
);
