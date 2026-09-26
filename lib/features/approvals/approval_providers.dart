import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../absences/absence_models.dart';
import '../timesheets/timesheet_models.dart';
import 'approval_api.dart';

final approvalApiProvider = Provider((ref) => ApprovalApi(ref.watch(dioProvider)));

final pendingAbsencesProvider = FutureProvider.autoDispose<List<AbsenceRequest>>(
  (ref) => ref.watch(approvalApiProvider).pendingAbsences(),
);

final pendingCancellationsProvider = FutureProvider.autoDispose<List<AbsenceRequest>>(
  (ref) => ref.watch(approvalApiProvider).pendingCancellations(),
);

final pendingTimesheetsProvider = FutureProvider.autoDispose<List<TimesheetEntry>>(
  (ref) => ref.watch(approvalApiProvider).pendingTimesheets(),
);
