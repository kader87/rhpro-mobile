import 'package:dio/dio.dart';

import 'superadmin_models.dart';

class SuperAdminApi {
  SuperAdminApi(this._dio);

  final Dio _dio;

  Future<SubscriptionInfo> currentSubscription() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/subscription/current');
    return SubscriptionInfo.fromJson(response.data!);
  }

  Future<void> cancelSubscription() => _dio.post('/api/subscription/cancel');

  Future<void> setAutoRenew(bool value) => _dio.put('/api/subscription/auto-renew', data: {'autoRenew': value});

  Future<List<CustomerAccount>> customerAccounts() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/customer-accounts', queryParameters: {'size': 100});
    final content = response.data!['content'] as List<dynamic>;
    return content.map((e) => CustomerAccount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createCustomerAccount({
    required String name,
    required String code,
    required String adminEmail,
    required String adminFirstName,
    required String adminLastName,
  }) =>
      _dio.post('/api/customer-accounts', data: {
        'name': name,
        'code': code,
        'adminEmail': adminEmail,
        'adminFirstName': adminFirstName,
        'adminLastName': adminLastName,
      });

  Future<void> activateAccount(String id) => _dio.patch('/api/customer-accounts/$id/activate');

  Future<void> deactivateAccount(String id) => _dio.patch('/api/customer-accounts/$id/deactivate');

  Future<List<PromoCode>> promoCodes() async {
    final response = await _dio.get<List<dynamic>>('/api/subscription/promo-codes');
    return response.data!.map((e) => PromoCode.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createPromoCode({required int discountAmountCents}) =>
      _dio.post('/api/subscription/promo-codes', data: {'discountAmountCents': discountAmountCents});
}
