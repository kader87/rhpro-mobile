import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/util/date_format.dart';
import 'hr_admin_models.dart';

class HrAdminApi {
  HrAdminApi(this._dio);

  final Dio _dio;

  Future<List<Holiday>> holidays({int? year}) async {
    final response = await _dio.get<List<dynamic>>('/api/holidays', queryParameters: year != null ? {'year': year} : null);
    return response.data!.map((e) => Holiday.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createHoliday({required DateTime date, required String label, bool isWorked = false}) =>
      _dio.post('/api/holidays', data: {'date': formatDateIso(date), 'label': label, 'isWorked': isWorked});

  Future<void> deleteHoliday(String id) => _dio.delete('/api/holidays/$id');

  Future<void> initializeYear(int year) => _dio.post('/api/holidays/initialize/$year');

  Future<LeavePolicy> leavePolicy() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/leave-policy');
    return LeavePolicy.fromJson(response.data!);
  }

  Future<void> updateLeavePolicy(LeavePolicy policy) => _dio.put('/api/leave-policy', data: policy.toRequestJson());

  Future<List<Department>> departments() async {
    final response = await _dio.get<List<dynamic>>('/api/departments');
    return response.data!.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createDepartment({required String name, String? description}) =>
      _dio.post('/api/departments', data: {'name': name, 'description': description});

  Future<void> deleteDepartment(String id) => _dio.delete('/api/departments/$id');

  /// Downloads the leave export CSV and saves it under the app's documents directory.
  Future<String> exportLeavesToCsv({required int month, required int year}) async {
    final response = await _dio.post<List<int>>(
      '/api/absences/export/csv',
      data: {'month': month, 'year': year, 'includeEmpty': false, 'extraColumns': <String>[]},
      options: Options(responseType: ResponseType.bytes),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/conges_${year}_$month.csv');
    await file.writeAsBytes(response.data!);
    return file.path;
  }
}
