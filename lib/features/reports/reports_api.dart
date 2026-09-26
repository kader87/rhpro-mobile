import 'package:dio/dio.dart';

import '../absences/absence_models.dart';

class ReportsApi {
  ReportsApi(this._dio);

  final Dio _dio;

  Future<List<AbsenceRequest>> teamAbsences() async {
    final response = await _dio.get<List<dynamic>>('/api/absences/team');
    return response.data!.map((e) => AbsenceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }
}
