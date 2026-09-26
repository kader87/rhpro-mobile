import 'package:dio/dio.dart';

import '../../core/util/date_format.dart';
import 'absence_models.dart';

class AbsenceApi {
  AbsenceApi(this._dio);

  final Dio _dio;

  Future<List<AbsenceRequest>> myRequests() async {
    final response = await _dio.get<List<dynamic>>('/api/absences/my-requests');
    return response.data!.map((e) => AbsenceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LeaveBalance> myBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/leave-balances/my-balance');
    return LeaveBalance.fromJson(response.data!);
  }

  Future<AbsenceRequest> create({
    required AbsenceType type,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    bool halfDayStart = false,
    bool halfDayEnd = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/absences',
      data: {
        'type': type.apiName,
        'startDate': formatDateIso(startDate),
        'endDate': formatDateIso(endDate),
        'reason': reason,
        'halfDayStart': halfDayStart,
        'halfDayEnd': halfDayEnd,
      },
    );
    return AbsenceRequest.fromJson(response.data!);
  }

  Future<AbsenceRequest> cancel(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/absences/$id/cancel');
    return AbsenceRequest.fromJson(response.data!);
  }
}
