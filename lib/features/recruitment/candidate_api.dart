import 'package:dio/dio.dart';

import 'candidate_models.dart';

class CandidateApi {
  CandidateApi(this._dio);

  final Dio _dio;

  Future<List<Candidate>> all() async {
    final response = await _dio.get<List<dynamic>>('/api/candidates');
    return response.data!.map((e) => Candidate.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Candidate> create({
    required String firstName,
    required String lastName,
    required String email,
    required String position,
    String? phone,
    String? notes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/candidates', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'position': position,
      'phone': phone,
      'notes': notes,
    });
    return Candidate.fromJson(response.data!);
  }

  Future<Candidate> updateStatus(String id, CandidateStatus status) async {
    final response = await _dio.patch<Map<String, dynamic>>('/api/candidates/$id/status', data: {'status': status.apiName});
    return Candidate.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> convertToEmployee(
    String id, {
    required String employeeId,
    required String department,
    required String dateOfJoining,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/candidates/$id/convert', data: {
      'employeeId': employeeId,
      'department': department,
      'dateOfJoining': dateOfJoining,
    });
    return response.data!;
  }
}
