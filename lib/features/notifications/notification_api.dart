import 'package:dio/dio.dart';

import 'notification_models.dart';

class NotificationApi {
  NotificationApi(this._dio);

  final Dio _dio;

  Future<List<AppNotification>> all() async {
    final response = await _dio.get<List<dynamic>>('/api/notifications/all');
    return response.data!.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final response = await _dio.get<dynamic>('/api/notifications/unread/count');
    return (response.data as num).toInt();
  }

  Future<void> markAsRead(String id) => _dio.put('/api/notifications/$id/read');

  Future<void> markAllAsRead() => _dio.put('/api/notifications/read-all');
}
