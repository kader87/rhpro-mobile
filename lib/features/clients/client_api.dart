import 'package:dio/dio.dart';

import 'client_models.dart';

class ClientApi {
  ClientApi(this._dio);

  final Dio _dio;

  Future<List<Client>> all() async {
    final response = await _dio.get<List<dynamic>>('/api/clients');
    return response.data!.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Client> create(Client client) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/clients', data: client.toRequestJson());
    return Client.fromJson(response.data!);
  }

  Future<Client> update(String id, Client client) async {
    final response = await _dio.put<Map<String, dynamic>>('/api/clients/$id', data: client.toRequestJson());
    return Client.fromJson(response.data!);
  }

  Future<void> toggleActive(String id) => _dio.patch('/api/clients/$id/toggle');

  Future<void> delete(String id) => _dio.delete('/api/clients/$id');
}
