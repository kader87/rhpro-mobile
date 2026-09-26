import '../../core/util/date_format.dart';

class Holiday {
  Holiday({required this.id, required this.date, required this.label, required this.isWorked});

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
        id: json['id'] as String,
        date: parseApiDate(json['date'] as String),
        label: json['label'] as String,
        isWorked: json['isWorked'] as bool? ?? false,
      );

  final String id;
  final DateTime date;
  final String label;
  final bool isWorked;
}

class LeavePolicy {
  LeavePolicy({
    required this.annualPaidLeave,
    required this.annualRtt,
    required this.maxCarryOverDays,
    required this.renewalMonth,
    required this.renewalDay,
    required this.enableProrata,
    required this.enableCarryOver,
  });

  factory LeavePolicy.fromJson(Map<String, dynamic> json) => LeavePolicy(
        annualPaidLeave: (json['annualPaidLeave'] as num).toDouble(),
        annualRtt: (json['annualRtt'] as num).toDouble(),
        maxCarryOverDays: (json['maxCarryOverDays'] as num).toDouble(),
        renewalMonth: json['renewalMonth'] as int,
        renewalDay: json['renewalDay'] as int,
        enableProrata: json['enableProrata'] as bool? ?? true,
        enableCarryOver: json['enableCarryOver'] as bool? ?? true,
      );

  final double annualPaidLeave;
  final double annualRtt;
  final double maxCarryOverDays;
  final int renewalMonth;
  final int renewalDay;
  final bool enableProrata;
  final bool enableCarryOver;

  Map<String, dynamic> toRequestJson() => {
        'annualPaidLeave': annualPaidLeave,
        'annualRtt': annualRtt,
        'maxCarryOverDays': maxCarryOverDays,
        'renewalMonth': renewalMonth,
        'renewalDay': renewalDay,
        'enableProrata': enableProrata,
        'enableCarryOver': enableCarryOver,
      };
}

class Department {
  Department({required this.id, required this.name, this.description, this.managerName, this.employeeCount});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        managerName: json['managerName'] as String?,
        employeeCount: (json['employeeCount'] as num?)?.toInt(),
      );

  final String id;
  final String name;
  final String? description;
  final String? managerName;
  final int? employeeCount;
}
