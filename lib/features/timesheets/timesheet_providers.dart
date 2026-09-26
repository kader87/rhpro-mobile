import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'timesheet_api.dart';
import 'timesheet_models.dart';

final timesheetApiProvider = Provider((ref) => TimesheetApi(ref.watch(dioProvider)));

DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
DateTime _endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

final currentMonthTimesheetProvider = FutureProvider.autoDispose<List<TimesheetEntry>>((ref) {
  final now = DateTime.now();
  return ref.watch(timesheetApiProvider).myEntries(startDate: _startOfMonth(now), endDate: _endOfMonth(now));
});

final activeActivitiesProvider = FutureProvider.autoDispose<List<Activity>>(
  (ref) => ref.watch(timesheetApiProvider).activeActivities(),
);
