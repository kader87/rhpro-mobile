import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../absences/absence_models.dart';
import 'reports_api.dart';

final reportsApiProvider = Provider((ref) => ReportsApi(ref.watch(dioProvider)));

final teamAbsencesReportProvider = FutureProvider.autoDispose<List<AbsenceRequest>>(
  (ref) => ref.watch(reportsApiProvider).teamAbsences(),
);
