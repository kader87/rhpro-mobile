import 'package:dio/dio.dart';

import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import 'activity_models.dart';

class BillableActivityApi {
  BillableActivityApi(this._dio);

  final Dio _dio;

  Future<List<BillableActivity>> all() async {
    final response = await _dio.get<List<dynamic>>('/api/activities');
    return response.data!.map((e) => BillableActivity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BillableActivity> create({
    required String name,
    required String clientId,
    required TimesheetUnit pricingUnit,
    String? description,
    double? price,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/activities', data: {
      'name': name,
      'clientId': clientId,
      'pricingUnit': pricingUnit.apiName,
      'description': description,
      'price': price,
    });
    return BillableActivity.fromJson(response.data!);
  }

  Future<void> toggleActive(String id) => _dio.patch('/api/activities/$id/toggle');

  Future<void> delete(String id) => _dio.delete('/api/activities/$id');

  Future<List<ActivityAssignment>> assignments() async {
    final response = await _dio.get<List<dynamic>>('/api/activity-assignments');
    return response.data!.map((e) => ActivityAssignment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> assign({required String activityId, required String userId, required DateTime startDate, DateTime? endDate}) =>
      _dio.post('/api/activity-assignments', data: {
        'activityId': activityId,
        'userId': userId,
        'startDate': formatDateIso(startDate),
        'endDate': endDate != null ? formatDateIso(endDate) : null,
      });

  Future<void> toggleAssignment(String id) => _dio.patch('/api/activity-assignments/$id/toggle');
}
