import '../../core/util/date_format.dart';

/// Curated, mobile-safe view of the backend's `UserResponse`. Deliberately
/// omits payroll/legal/personal fields (IBAN, salary, birth info, SSN, ...)
/// that a manager viewing a teammate's profile on mobile has no reason to see.
class EmployeeSummary {
  EmployeeSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phone,
    this.department,
    this.employeeId,
    this.dateOfJoining,
    this.managerName,
    this.employmentContractType,
    this.active,
  });

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) => EmployeeSummary(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String,
        role: json['role'] as String,
        phone: json['phone'] as String?,
        department: json['department'] as String?,
        employeeId: json['employeeId'] as String?,
        dateOfJoining: json['dateOfJoining'] != null ? parseApiDate(json['dateOfJoining'] as String) : null,
        managerName: json['managerName'] as String?,
        employmentContractType: json['employmentContractType'] as String?,
        active: json['active'] as bool?,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phone;
  final String? department;
  final String? employeeId;
  final DateTime? dateOfJoining;
  final String? managerName;
  final String? employmentContractType;
  final bool? active;

  String get fullName => '$firstName $lastName'.trim();
}
