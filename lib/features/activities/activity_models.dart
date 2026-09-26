import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';
import '../clients/client_models.dart';

/// Billable, client-linked activity (admin CRUD). Distinct from the lightweight
/// `Activity` in features/timesheets (name-only, used for the "my entries" dropdown).
class BillableActivity {
  BillableActivity({
    required this.id,
    required this.name,
    required this.pricingUnit,
    required this.active,
    this.description,
    this.price,
    this.client,
  });

  factory BillableActivity.fromJson(Map<String, dynamic> json) => BillableActivity(
        id: json['id'] as String,
        name: json['name'] as String,
        pricingUnit: TimesheetUnitJson.fromJson(json['pricingUnit'] as String),
        active: json['active'] as bool? ?? true,
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble(),
        client: json['client'] != null ? Client.fromJson(json['client'] as Map<String, dynamic>) : null,
      );

  final String id;
  final String name;
  final TimesheetUnit pricingUnit;
  final bool active;
  final String? description;
  final double? price;
  final Client? client;
}

class ActivityAssignment {
  ActivityAssignment({
    required this.id,
    required this.activityName,
    required this.userName,
    required this.startDate,
    this.endDate,
    required this.active,
  });

  factory ActivityAssignment.fromJson(Map<String, dynamic> json) => ActivityAssignment(
        id: json['id'] as String,
        activityName: json['activityName'] as String,
        userName: json['userName'] as String,
        startDate: parseApiDate(json['startDate'] as String),
        endDate: json['endDate'] != null ? parseApiDate(json['endDate'] as String) : null,
        active: json['active'] as bool? ?? true,
      );

  final String id;
  final String activityName;
  final String userName;
  final DateTime startDate;
  final DateTime? endDate;
  final bool active;
}
