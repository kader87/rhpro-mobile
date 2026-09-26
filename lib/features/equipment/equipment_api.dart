import 'package:dio/dio.dart';

import '../../core/util/date_format.dart';
import 'equipment_models.dart';

class EquipmentApi {
  EquipmentApi(this._dio);

  final Dio _dio;

  Future<List<EquipmentItem>> items() async {
    final response = await _dio.get<List<dynamic>>('/api/equipment-items');
    return response.data!.map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createItem({required String name, required int alertThreshold, String? description}) => _dio.post(
        '/api/equipment-items',
        data: {'name': name, 'description': description, 'alertThreshold': alertThreshold, 'totalStock': 0, 'assignedStock': 0, 'active': true},
      );

  Future<void> toggleItemActive(String id) => _dio.patch('/api/equipment-items/$id/toggle-active');

  Future<List<EquipmentPurchase>> purchases() async {
    final response = await _dio.get<List<dynamic>>('/api/equipment-purchases');
    return response.data!.map((e) => EquipmentPurchase.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createPurchase({
    required String itemId,
    required int quantity,
    required double unitPrice,
    required DateTime purchaseDate,
  }) =>
      _dio.post('/api/equipment-purchases', data: {
        'itemId': itemId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'purchaseDate': formatDateIso(purchaseDate),
      });

  Future<List<EquipmentAssignment>> myAssignments() async {
    final response = await _dio.get<List<dynamic>>('/api/equipment-assignments/my-assignments');
    return response.data!.map((e) => EquipmentAssignment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EquipmentAssignment>> allAssignments() async {
    final response = await _dio.get<List<dynamic>>('/api/equipment-assignments');
    return response.data!.map((e) => EquipmentAssignment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> assign({
    required String itemId,
    required String employeeId,
    required int quantity,
    required DateTime assignmentDate,
  }) =>
      _dio.post('/api/equipment-assignments', data: {
        'itemId': itemId,
        'employeeId': employeeId,
        'quantity': quantity,
        'assignmentDate': formatDateIso(assignmentDate),
        'isActive': true,
      });

  Future<void> returnAssignment(String id, {String notes = ''}) =>
      _dio.post('/api/equipment-assignments/$id/return', data: {'notes': notes});
}
