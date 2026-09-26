import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'finance_api.dart';
import 'finance_models.dart';

final financeApiProvider = Provider((ref) => FinanceApi(ref.watch(dioProvider)));

final invoicableEntriesProvider = FutureProvider.autoDispose<List<InvoicableEntry>>(
  (ref) => ref.watch(financeApiProvider).invoicableEntries(),
);

final invoicesProvider = FutureProvider.autoDispose<List<Invoice>>((ref) => ref.watch(financeApiProvider).invoices());

final profitabilityProvider = FutureProvider.autoDispose<List<EmployeeProfitability>>(
  (ref) => ref.watch(financeApiProvider).profitability(),
);
