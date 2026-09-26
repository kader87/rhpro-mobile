import 'package:dio/dio.dart';

import 'planning_models.dart';

class PlanningApi {
  PlanningApi(this._dio);

  final Dio _dio;

  Future<List<ScheduledShift>> forEmployee(String userId) async {
    final response = await _dio.get<List<dynamic>>('/api/planning/employee/$userId');
    return response.data!.map((e) => ScheduledShift.fromJson(e as Map<String, dynamic>)).toList();
  }
}
