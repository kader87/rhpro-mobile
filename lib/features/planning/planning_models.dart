import '../../core/models/timesheet_unit.dart';
import '../../core/util/date_format.dart';

enum ShiftStatus { planned, convertedToCra, cancelled }

extension ShiftStatusJson on ShiftStatus {
  static ShiftStatus fromJson(String value) => switch (value) {
        'CONVERTED_TO_CRA' => ShiftStatus.convertedToCra,
        'CANCELLED' => ShiftStatus.cancelled,
        _ => ShiftStatus.planned,
      };

  String get label => switch (this) {
        ShiftStatus.planned => 'Planifié',
        ShiftStatus.convertedToCra => 'Converti en CRA',
        ShiftStatus.cancelled => 'Annulé',
      };
}

class ScheduledShift {
  ScheduledShift({
    required this.id,
    required this.activityName,
    required this.clientName,
    required this.startDate,
    required this.endDate,
    required this.dailyAmount,
    required this.unit,
    required this.status,
    this.note,
  });

  factory ScheduledShift.fromJson(Map<String, dynamic> json) => ScheduledShift(
        id: json['id'] as String,
        activityName: json['activityName'] as String,
        clientName: json['clientName'] as String?,
        startDate: parseApiDate(json['startDate'] as String),
        endDate: parseApiDate(json['endDate'] as String),
        dailyAmount: (json['dailyAmount'] as num).toDouble(),
        unit: TimesheetUnitJson.fromJson(json['unit'] as String),
        status: ShiftStatusJson.fromJson(json['status'] as String),
        note: json['note'] as String?,
      );

  final String id;
  final String activityName;
  final String? clientName;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyAmount;
  final TimesheetUnit unit;
  final ShiftStatus status;
  final String? note;
}
