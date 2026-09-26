import 'package:dio/dio.dart';

import '../clients/client_models.dart';
import 'prospect_models.dart';

class ProspectApi {
  ProspectApi(this._dio);

  final Dio _dio;

  Future<List<Prospect>> all() async {
    final response = await _dio.get<List<dynamic>>('/api/prospects');
    return response.data!.map((e) => Prospect.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Prospect> create({
    required String companyName,
    required String contactName,
    String? email,
    String? phone,
    String? city,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/prospects', data: {
      'companyName': companyName,
      'contactName': contactName,
      'email': email,
      'phone': phone,
      'city': city,
    });
    return Prospect.fromJson(response.data!);
  }

  Future<Prospect> updateStatus(Prospect prospect, ProspectStatus status) async {
    final response = await _dio.put<Map<String, dynamic>>('/api/prospects/${prospect.id}', data: {
      'companyName': prospect.companyName,
      'contactName': prospect.contactName,
      'email': prospect.email,
      'phone': prospect.phone,
      'city': prospect.city,
      'status': status.apiName,
    });
    return Prospect.fromJson(response.data!);
  }

  Future<Prospect> addComment(String prospectId, String text) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/prospects/$prospectId/comments', data: {'text': text});
    return Prospect.fromJson(response.data!);
  }

  /// Mirrors the web app's client-side `extractClientData`: a transformed
  /// prospect has no dedicated "convert" backend endpoint, so we just create
  /// a Client from the prospect's fields.
  Future<Client> convertToClient(Prospect prospect) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/clients', data: {
      'name': prospect.companyName,
      'email': prospect.email,
      'phone': prospect.phone,
      'city': prospect.city,
    });
    return Client.fromJson(response.data!);
  }

  Future<List<Devis>> devisForProspect(String prospectId) async {
    final response = await _dio.get<List<dynamic>>('/api/devis/prospect/$prospectId');
    return response.data!.map((e) => Devis.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Devis> createDevis({required String prospectId, required String prospectName, required List<DevisLine> lines}) async {
    final totalHt = lines.fold<double>(0, (sum, l) => sum + l.totalHt);
    final taxAmount = lines.fold<double>(0, (sum, l) => sum + l.totalHt * l.taxRate / 100);
    final response = await _dio.post<Map<String, dynamic>>('/api/devis', data: {
      'prospectId': prospectId,
      'prospectName': prospectName,
      'lines': lines.map((l) => l.toJson()).toList(),
      'totalHt': totalHt,
      'taxAmount': taxAmount,
      'totalTtc': totalHt + taxAmount,
    });
    return Devis.fromJson(response.data!);
  }
}
