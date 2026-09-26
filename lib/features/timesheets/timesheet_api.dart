import 'package:dio/dio.dart';

import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import 'timesheet_models.dart';

class TimesheetApi {
  TimesheetApi(this._dio);

  final Dio _dio;

  Future<List<TimesheetEntry>> myEntries({required DateTime startDate, required DateTime endDate}) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/timesheets/my-entries',
      queryParameters: {'startDate': formatDateIso(startDate), 'endDate': formatDateIso(endDate)},
    );
    return response.data!.map((e) => TimesheetEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Activity>> activeActivities() async {
    final response = await _dio.get<List<dynamic>>('/api/activities/active');
    return response.data!.map((e) => Activity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TimesheetEntry>> addEntry({
    required String activityId,
    required DateTime entryDate,
    required double amount,
    required TimesheetUnit unit,
    String? note,
  }) async {
    final response = await _dio.post<List<dynamic>>(
      '/api/timesheets',
      data: [
        {
          'activityId': activityId,
          'entryDate': formatDateIso(entryDate),
          'amount': amount,
          'unit': unit.apiName,
          'note': note,
        }
      ],
    );
    return response.data!.map((e) => TimesheetEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
