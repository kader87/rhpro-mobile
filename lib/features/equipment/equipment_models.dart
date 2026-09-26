import '../../core/util/date_format.dart';

class EquipmentItem {
  EquipmentItem({
    required this.id,
    required this.name,
    required this.alertThreshold,
    required this.totalStock,
    required this.assignedStock,
    required this.availableStock,
    required this.active,
    this.description,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) => EquipmentItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        alertThreshold: json['alertThreshold'] as int,
        totalStock: json['totalStock'] as int,
        assignedStock: json['assignedStock'] as int,
        availableStock: json['availableStock'] as int,
        active: json['active'] as bool? ?? true,
      );

  final String id;
  final String name;
  final String? description;
  final int alertThreshold;
  final int totalStock;
  final int assignedStock;
  final int availableStock;
  final bool active;

  bool get isLowStock => availableStock <= alertThreshold;
}

class EquipmentPurchase {
  EquipmentPurchase({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.purchaseDate,
  });

  factory EquipmentPurchase.fromJson(Map<String, dynamic> json) => EquipmentPurchase(
        id: json['id'] as String,
        itemName: json['itemName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        purchaseDate: parseApiDate(json['purchaseDate'] as String),
      );

  final String id;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime purchaseDate;
}

class EquipmentAssignment {
  EquipmentAssignment({
    required this.id,
    required this.itemName,
    required this.employeeName,
    required this.quantity,
    required this.assignmentDate,
    required this.isActive,
    this.returnDate,
  });

  factory EquipmentAssignment.fromJson(Map<String, dynamic> json) => EquipmentAssignment(
        id: json['id'] as String,
        itemName: json['itemName'] as String,
        employeeName: json['employeeName'] as String,
        quantity: json['quantity'] as int,
        assignmentDate: parseApiDate(json['assignmentDate'] as String),
        isActive: json['isActive'] as bool? ?? true,
        returnDate: json['returnDate'] != null ? parseApiDate(json['returnDate'] as String) : null,
      );

  final String id;
  final String itemName;
  final String employeeName;
  final int quantity;
  final DateTime assignmentDate;
  final bool isActive;
  final DateTime? returnDate;
}
