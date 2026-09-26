import 'package:dio/dio.dart';

import '../../core/util/date_format.dart';
import 'talent_models.dart';

class TalentApi {
  TalentApi(this._dio);

  final Dio _dio;

  // Interviews
  Future<List<Interview>> myInterviews() async {
    final response = await _dio.get<List<dynamic>>('/api/interviews/my-interviews');
    return response.data!.map((e) => Interview.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Interview>> allInterviews() async {
    final response = await _dio.get<List<dynamic>>('/api/interviews');
    return response.data!.map((e) => Interview.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createInterview({
    required String employeeId,
    required String interviewerId,
    required String type,
    required DateTime scheduledDate,
    String? objectives,
  }) =>
      _dio.post('/api/interviews', data: {
        'employeeId': employeeId,
        'interviewerId': interviewerId,
        'type': type,
        'scheduledDate': scheduledDate.toIso8601String(),
        'objectives': objectives,
      });

  Future<void> cancelInterview(String id) => _dio.post('/api/interviews/$id/cancel');

  // Trainings
  Future<List<Training>> trainings() async {
    final response = await _dio.get<List<dynamic>>('/api/trainings');
    return response.data!.map((e) => Training.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createTraining({required String title, String? description, String? provider, int? durationHours}) =>
      _dio.post('/api/trainings', data: {'title': title, 'description': description, 'provider': provider, 'durationHours': durationHours});

  Future<List<TrainingEnrollment>> myEnrollments() async {
    final response = await _dio.get<List<dynamic>>('/api/training-enrollments/my-enrollments');
    return response.data!.map((e) => TrainingEnrollment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> enroll({required String employeeId, required String trainingId}) => _dio.post('/api/training-enrollments', data: {
        'employeeId': employeeId,
        'trainingId': trainingId,
        'status': 'PLANNED',
        'enrollmentDate': formatDateIso(DateTime.now()),
      });

  // Skills
  Future<List<Skill>> skills() async {
    final response = await _dio.get<List<dynamic>>('/api/skills');
    return response.data!.map((e) => Skill.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createSkill({required String name, String? category}) =>
      _dio.post('/api/skills', data: {'name': name, 'category': category});

  Future<List<EmployeeSkill>> mySkills() async {
    final response = await _dio.get<List<dynamic>>('/api/employee-skills/my-skills');
    return response.data!.map((e) => EmployeeSkill.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> assignSkill({required String employeeId, required String skillId, required SkillLevel level}) =>
      _dio.post('/api/employee-skills', data: {'employeeId': employeeId, 'skillId': skillId, 'level': level.apiName});
}
