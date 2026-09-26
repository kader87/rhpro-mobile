import 'package:dio/dio.dart';

import 'finance_models.dart';

class FinanceApi {
  FinanceApi(this._dio);

  final Dio _dio;

  Future<List<InvoicableEntry>> invoicableEntries() async {
    final response = await _dio.get<List<dynamic>>('/api/invoices/invoicable-entries');
    return response.data!.map((e) => InvoicableEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Invoice> generateInvoice(List<String> entryIds) async {
    final response = await _dio.post<Map<String, dynamic>>('/api/invoices/generate', data: entryIds);
    return Invoice.fromJson(response.data!);
  }

  Future<List<Invoice>> invoices() async {
    final response = await _dio.get<List<dynamic>>('/api/invoices');
    return response.data!.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> mostActiveClients() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/invoices/stats/most-active-clients');
    return response.data!;
  }

  Future<List<EmployeeProfitability>> profitability() async {
    final response = await _dio.get<List<dynamic>>('/api/profitability');
    return response.data!.map((e) => EmployeeProfitability.fromJson(e as Map<String, dynamic>)).toList();
  }
}
