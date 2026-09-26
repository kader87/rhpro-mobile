/// Shared between planning (`ScheduledShiftResponse`) and timesheets (`TimesheetEntryResponse`).
enum TimesheetUnit { hours, days }

extension TimesheetUnitJson on TimesheetUnit {
  static TimesheetUnit fromJson(String value) => value == 'DAYS' ? TimesheetUnit.days : TimesheetUnit.hours;

  String get apiName => this == TimesheetUnit.days ? 'DAYS' : 'HOURS';

  String get label => this == TimesheetUnit.days ? 'j' : 'h';
}
