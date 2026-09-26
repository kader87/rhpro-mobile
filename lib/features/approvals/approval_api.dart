import 'package:dio/dio.dart';

import '../../core/util/date_format.dart';
import '../absences/absence_models.dart';
import '../timesheets/timesheet_models.dart';

class ApprovalApi {
  ApprovalApi(this._dio);

  final Dio _dio;

  Future<List<AbsenceRequest>> pendingAbsences() async {
    final response = await _dio.get<List<dynamic>>('/api/absences/pending/my-team');
    return response.data!.map((e) => AbsenceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approveAbsence(String id) => _dio.post('/api/absences/$id/approve');

  Future<void> rejectAbsence(String id, String reason) =>
      _dio.post('/api/absences/$id/reject', data: {'rejectionReason': reason});

  Future<List<AbsenceRequest>> pendingCancellations() async {
    final response = await _dio.get<List<dynamic>>('/api/absences/pending-cancellations/my-team');
    return response.data!.map((e) => AbsenceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approveCancellation(String id) => _dio.post('/api/absences/$id/cancel/approve');

  Future<void> rejectCancellation(String id) => _dio.post('/api/absences/$id/cancel/reject');

  Future<List<TimesheetEntry>> pendingTimesheets() async {
    final response = await _dio.get<List<dynamic>>('/api/timesheets/pending');
    return response.data!.map((e) => TimesheetEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// The backend approves/rejects a whole date range per employee, not single entries.
  /// We pass the entry's own date as both bounds so the action only affects that entry.
  Future<void> approveTimesheetEntry(TimesheetEntry entry) => _dio.post(
        '/api/timesheets/employee/${entry.userId}/approve',
        queryParameters: {'startDate': formatDateIso(entry.entryDate), 'endDate': formatDateIso(entry.entryDate)},
      );

  Future<void> rejectTimesheetEntry(TimesheetEntry entry, String reason) => _dio.post(
        '/api/timesheets/employee/${entry.userId}/reject',
        queryParameters: {
          'startDate': formatDateIso(entry.entryDate),
          'endDate': formatDateIso(entry.entryDate),
          'reason': reason,
        },
      );
}
