import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'absence_api.dart';
import 'absence_models.dart';

final absenceApiProvider = Provider((ref) => AbsenceApi(ref.watch(dioProvider)));

final myAbsencesProvider = FutureProvider.autoDispose<List<AbsenceRequest>>(
  (ref) => ref.watch(absenceApiProvider).myRequests(),
);

final myLeaveBalanceProvider = FutureProvider.autoDispose<LeaveBalance>(
  (ref) => ref.watch(absenceApiProvider).myBalance(),
);
