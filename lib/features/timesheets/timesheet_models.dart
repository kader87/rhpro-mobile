import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';

enum TimesheetStatus { draft, submitted, approved, rejected }

extension TimesheetStatusJson on TimesheetStatus {
  static TimesheetStatus fromJson(String value) => TimesheetStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == value,
        orElse: () => TimesheetStatus.draft,
      );

  String get label => switch (this) {
        TimesheetStatus.draft => 'Brouillon',
        TimesheetStatus.submitted => 'Soumis',
        TimesheetStatus.approved => 'Approuvé',
        TimesheetStatus.rejected => 'Rejeté',
      };
}

class TimesheetEntry {
  TimesheetEntry({
    required this.id,
    required this.userId,
    this.employeeName,
    required this.activityId,
    required this.activityName,
    required this.entryDate,
    required this.amount,
    required this.unit,
    required this.status,
    this.note,
  });

  factory TimesheetEntry.fromJson(Map<String, dynamic> json) => TimesheetEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        employeeName: json['employeeName'] as String?,
        activityId: json['activityId'] as String,
        activityName: json['activityName'] as String,
        entryDate: parseApiDate(json['entryDate'] as String),
        amount: (json['amount'] as num).toDouble(),
        unit: TimesheetUnitJson.fromJson(json['unit'] as String),
        status: TimesheetStatusJson.fromJson(json['status'] as String),
        note: json['note'] as String?,
      );

  final String id;
  final String userId;
  final String? employeeName;
  final String activityId;
  final String activityName;
  final DateTime entryDate;
  final double amount;
  final TimesheetUnit unit;
  final TimesheetStatus status;
  final String? note;
}

class Activity {
  Activity({required this.id, required this.name});

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  final String id;
  final String name;
}
