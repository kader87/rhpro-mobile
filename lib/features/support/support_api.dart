import 'package:dio/dio.dart';

import 'support_models.dart';

class SupportApi {
  SupportApi(this._dio);

  final Dio _dio;

  Future<void> createTicket({required String subject, required String message}) =>
      _dio.post('/api/support', data: {'subject': subject, 'message': message});

  Future<List<SupportMessage>> myMessages() async {
    final response = await _dio.get<List<dynamic>>('/api/support/my-messages');
    return response.data!.map((e) => SupportMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> acknowledge(String id) => _dio.post('/api/support/$id/acknowledge');

  Future<List<SupportMessage>> inbox() async {
    final response = await _dio.get<List<dynamic>>('/api/support');
    return response.data!.map((e) => SupportMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> reply(String id, String reply) => _dio.post('/api/support/$id/reply', data: {'reply': reply});

  Future<void> close(String id) => _dio.post('/api/support/$id/close');
}
