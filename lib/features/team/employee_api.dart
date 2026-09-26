import 'package:dio/dio.dart';

import 'employee_models.dart';

class EmployeeApi {
  EmployeeApi(this._dio);

  final Dio _dio;

  Future<List<EmployeeSummary>> myTeam() async {
    final response = await _dio.get<List<dynamic>>('/api/users/my-team');
    return response.data!.map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EmployeeSummary> byId(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/users/$id');
    return EmployeeSummary.fromJson(response.data!);
  }

  Future<List<EmployeeSummary>> allActive() async {
    final response = await _dio.get<List<dynamic>>('/api/users/active');
    return response.data!.map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EmployeeSummary>> departmentColleagues() async {
    final response = await _dio.get<List<dynamic>>('/api/users/department/mine');
    return response.data!.map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EmployeeSummary>> allUsers() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/users', queryParameters: {'size': 200});
    final content = response.data!['content'] as List<dynamic>;
    return content.map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> create({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    required String department,
    required String employeeId,
    required String dateOfJoining,
    String? phone,
    String? employmentContractType,
  }) =>
      _dio.post('/api/users', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'department': department,
        'employeeId': employeeId,
        'dateOfJoining': dateOfJoining,
        'phone': phone,
        'employmentContractType': employmentContractType,
      });

  Future<void> update(
    String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? department,
    String? phone,
    String? employmentContractType,
  }) =>
      _dio.put('/api/users/$id', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'department': department,
        'phone': phone,
        'employmentContractType': employmentContractType,
      });

  Future<void> activate(String id) => _dio.put('/api/users/$id/activate');

  Future<void> deactivate(String id) => _dio.put('/api/users/$id/deactivate');
}
