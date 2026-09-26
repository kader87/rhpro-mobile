import '../../core/models/employee_ref.dart';
import '../../core/util/date_format.dart';

enum AbsenceStatus { pending, approved, rejected, canceled }

extension AbsenceStatusJson on AbsenceStatus {
  static AbsenceStatus fromJson(String value) =>
      AbsenceStatus.values.firstWhere((e) => e.name.toUpperCase() == value, orElse: () => AbsenceStatus.pending);

  String get label => switch (this) {
        AbsenceStatus.pending => 'En attente',
        AbsenceStatus.approved => 'Approuvée',
        AbsenceStatus.rejected => 'Refusée',
        AbsenceStatus.canceled => 'Annulée',
      };
}

enum AbsenceType {
  paidLeave,
  rtt,
  compensatoryLeave,
  sickLeave,
  occupationalIllness,
  workAccident,
  maternityLeave,
  paternityLeave,
  parentalLeave,
  unpaidLeave,
  familyEvent,
  training,
  justifiedAbsence,
  unjustifiedAbsence,
  medicalAppointment,
}

extension AbsenceTypeJson on AbsenceType {
  static const _apiNames = {
    AbsenceType.paidLeave: 'PAID_LEAVE',
    AbsenceType.rtt: 'RTT',
    AbsenceType.compensatoryLeave: 'COMPENSATORY_LEAVE',
    AbsenceType.sickLeave: 'SICK_LEAVE',
    AbsenceType.occupationalIllness: 'OCCUPATIONAL_ILLNESS',
    AbsenceType.workAccident: 'WORK_ACCIDENT',
    AbsenceType.maternityLeave: 'MATERNITY_LEAVE',
    AbsenceType.paternityLeave: 'PATERNITY_LEAVE',
    AbsenceType.parentalLeave: 'PARENTAL_LEAVE',
    AbsenceType.unpaidLeave: 'UNPAID_LEAVE',
    AbsenceType.familyEvent: 'FAMILY_EVENT',
    AbsenceType.training: 'TRAINING',
    AbsenceType.justifiedAbsence: 'JUSTIFIED_ABSENCE',
    AbsenceType.unjustifiedAbsence: 'UNJUSTIFIED_ABSENCE',
    AbsenceType.medicalAppointment: 'MEDICAL_APPOINTMENT',
  };

  static const _labels = {
    AbsenceType.paidLeave: 'Congés payés',
    AbsenceType.rtt: 'RTT',
    AbsenceType.compensatoryLeave: 'Repos compensateur',
    AbsenceType.sickLeave: 'Arrêt maladie',
    AbsenceType.occupationalIllness: 'Maladie professionnelle',
    AbsenceType.workAccident: 'Accident du travail',
    AbsenceType.maternityLeave: 'Congé maternité',
    AbsenceType.paternityLeave: 'Congé paternité',
    AbsenceType.parentalLeave: 'Congé parental',
    AbsenceType.unpaidLeave: 'Congé sans solde',
    AbsenceType.familyEvent: 'Événement familial',
    AbsenceType.training: 'Formation',
    AbsenceType.justifiedAbsence: 'Absence justifiée',
    AbsenceType.unjustifiedAbsence: 'Absence injustifiée',
    AbsenceType.medicalAppointment: 'Rendez-vous médical',
  };

  static AbsenceType fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get apiName => _apiNames[this]!;

  String get label => _labels[this]!;
}

class AbsenceRequest {
  AbsenceRequest({
    required this.id,
    required this.employee,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason,
    this.rejectionReason,
    this.workingDays,
  });

  factory AbsenceRequest.fromJson(Map<String, dynamic> json) => AbsenceRequest(
        id: json['id'] as String,
        employee: EmployeeRef.fromJson(json['employee'] as Map<String, dynamic>),
        type: AbsenceTypeJson.fromJson(json['type'] as String),
        startDate: parseApiDate(json['startDate'] as String),
        endDate: parseApiDate(json['endDate'] as String),
        status: AbsenceStatusJson.fromJson(json['status'] as String),
        reason: json['reason'] as String?,
        rejectionReason: json['rejectionReason'] as String?,
        workingDays: (json['workingDays'] as num?)?.toDouble(),
      );

  final String id;
  final EmployeeRef employee;
  final AbsenceType type;
  final DateTime startDate;
  final DateTime endDate;
  final AbsenceStatus status;
  final String? reason;
  final String? rejectionReason;
  final double? workingDays;
}

class LeaveBalance {
  LeaveBalance({
    required this.year,
    required this.paidLeaveBalance,
    required this.paidLeaveTotal,
    required this.rttBalance,
    required this.rttTotal,
    required this.compensatoryLeaveBalance,
    required this.compensatoryLeaveTotal,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => LeaveBalance(
        year: json['year'] as int,
        paidLeaveBalance: (json['paidLeaveBalance'] as num).toDouble(),
        paidLeaveTotal: (json['paidLeaveTotal'] as num).toDouble(),
        rttBalance: (json['rttBalance'] as num).toDouble(),
        rttTotal: (json['rttTotal'] as num).toDouble(),
        compensatoryLeaveBalance: (json['compensatoryLeaveBalance'] as num).toDouble(),
        compensatoryLeaveTotal: (json['compensatoryLeaveTotal'] as num).toDouble(),
      );

  final int year;
  final double paidLeaveBalance;
  final double paidLeaveTotal;
  final double rttBalance;
  final double rttTotal;
  final double compensatoryLeaveBalance;
  final double compensatoryLeaveTotal;
}
