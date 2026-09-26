import '../../core/util/date_format.dart';

enum InterviewStatus {
  toSchedule,
  scheduled,
  completed,
  pendingEmployeeSignature,
  pendingEmployerSignature,
  signed,
  archived,
  cancelled
}

extension InterviewStatusJson on InterviewStatus {
  static const _apiNames = {
    InterviewStatus.toSchedule: 'TO_SCHEDULE',
    InterviewStatus.scheduled: 'SCHEDULED',
    InterviewStatus.completed: 'COMPLETED',
    InterviewStatus.pendingEmployeeSignature: 'PENDING_EMPLOYEE_SIGNATURE',
    InterviewStatus.pendingEmployerSignature: 'PENDING_EMPLOYER_SIGNATURE',
    InterviewStatus.signed: 'SIGNED',
    InterviewStatus.archived: 'ARCHIVED',
    InterviewStatus.cancelled: 'CANCELLED',
  };

  static InterviewStatus fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get label => switch (this) {
        InterviewStatus.toSchedule => 'À planifier',
        InterviewStatus.scheduled => 'Planifié',
        InterviewStatus.completed => 'Terminé',
        InterviewStatus.pendingEmployeeSignature => 'Attente signature salarié',
        InterviewStatus.pendingEmployerSignature => 'Attente signature employeur',
        InterviewStatus.signed => 'Signé',
        InterviewStatus.archived => 'Archivé',
        InterviewStatus.cancelled => 'Annulé',
      };
}

class Interview {
  Interview({
    required this.id,
    required this.employeeName,
    required this.interviewerName,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.objectives,
  });

  factory Interview.fromJson(Map<String, dynamic> json) => Interview(
        id: json['id'] as String,
        employeeName: json['employeeName'] as String,
        interviewerName: json['interviewerName'] as String,
        type: json['type'] as String,
        status: InterviewStatusJson.fromJson(json['status'] as String),
        scheduledDate: DateTime.parse(json['scheduledDate'] as String),
        objectives: json['objectives'] as String?,
      );

  final String id;
  final String employeeName;
  final String interviewerName;
  final String type;
  final InterviewStatus status;
  final DateTime scheduledDate;
  final String? objectives;
}

enum TrainingStatus { planned, inProgress, completed, cancelled }

extension TrainingStatusJson on TrainingStatus {
  static const _apiNames = {
    TrainingStatus.planned: 'PLANNED',
    TrainingStatus.inProgress: 'IN_PROGRESS',
    TrainingStatus.completed: 'COMPLETED',
    TrainingStatus.cancelled: 'CANCELLED',
  };

  static TrainingStatus fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get apiName => _apiNames[this]!;

  String get label => switch (this) {
        TrainingStatus.planned => 'Planifiée',
        TrainingStatus.inProgress => 'En cours',
        TrainingStatus.completed => 'Terminée',
        TrainingStatus.cancelled => 'Annulée',
      };
}

class Training {
  Training({required this.id, required this.title, required this.active, this.description, this.provider, this.durationHours});

  factory Training.fromJson(Map<String, dynamic> json) => Training(
        id: json['id'] as String,
        title: json['title'] as String,
        active: json['active'] as bool? ?? true,
        description: json['description'] as String?,
        provider: json['provider'] as String?,
        durationHours: json['durationHours'] as int?,
      );

  final String id;
  final String title;
  final bool active;
  final String? description;
  final String? provider;
  final int? durationHours;
}

class TrainingEnrollment {
  TrainingEnrollment({
    required this.id,
    required this.trainingTitle,
    required this.status,
    required this.enrollmentDate,
    this.employeeName,
  });

  factory TrainingEnrollment.fromJson(Map<String, dynamic> json) => TrainingEnrollment(
        id: json['id'] as String,
        trainingTitle: json['trainingTitle'] as String,
        status: TrainingStatusJson.fromJson(json['status'] as String),
        enrollmentDate: parseApiDate(json['enrollmentDate'] as String),
        employeeName: json['employeeName'] as String?,
      );

  final String id;
  final String trainingTitle;
  final TrainingStatus status;
  final DateTime enrollmentDate;
  final String? employeeName;
}

enum SkillLevel { beginner, intermediate, advanced, expert }

extension SkillLevelJson on SkillLevel {
  static SkillLevel fromJson(String value) =>
      SkillLevel.values.firstWhere((e) => e.name.toUpperCase() == value, orElse: () => SkillLevel.beginner);

  String get apiName => name.toUpperCase();

  String get label => switch (this) {
        SkillLevel.beginner => 'Débutant',
        SkillLevel.intermediate => 'Intermédiaire',
        SkillLevel.advanced => 'Avancé',
        SkillLevel.expert => 'Expert',
      };
}

class Skill {
  Skill({required this.id, required this.name, this.category});

  factory Skill.fromJson(Map<String, dynamic> json) =>
      Skill(id: json['id'] as String, name: json['name'] as String, category: json['category'] as String?);

  final String id;
  final String name;
  final String? category;
}

class EmployeeSkill {
  EmployeeSkill({required this.id, required this.skillName, required this.level, this.employeeName});

  factory EmployeeSkill.fromJson(Map<String, dynamic> json) => EmployeeSkill(
        id: json['id'] as String,
        skillName: json['skillName'] as String,
        level: SkillLevelJson.fromJson(json['level'] as String),
        employeeName: json['employeeName'] as String?,
      );

  final String id;
  final String skillName;
  final SkillLevel level;
  final String? employeeName;
}
