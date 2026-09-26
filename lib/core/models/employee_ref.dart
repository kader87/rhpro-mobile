/// Lightweight view of a `UserResponse` as nested inside other DTOs
/// (e.g. `AbsenceRequestResponse.employee/approver`). The backend sends the
/// full ~50-field HR payload there; the mobile app only needs the name.
class EmployeeRef {
  EmployeeRef({required this.id, required this.firstName, required this.lastName});

  factory EmployeeRef.fromJson(Map<String, dynamic> json) => EmployeeRef(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
      );

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName'.trim();
}
