import '../../core/util/date_format.dart';

enum DocumentType { payslip, expenseReport, personal, miscellaneous }

extension DocumentTypeJson on DocumentType {
  static const _apiNames = {
    DocumentType.payslip: 'PAYSLIP',
    DocumentType.expenseReport: 'EXPENSE_REPORT',
    DocumentType.personal: 'PERSONAL',
    DocumentType.miscellaneous: 'MISCELLANEOUS',
  };

  static const _labels = {
    DocumentType.payslip: 'Bulletins de paie',
    DocumentType.expenseReport: 'Notes de frais',
    DocumentType.personal: 'Documents personnels',
    DocumentType.miscellaneous: 'Divers',
  };

  static DocumentType fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get apiName => _apiNames[this]!;

  String get label => _labels[this]!;
}

class RhDocument {
  RhDocument({
    required this.id,
    required this.name,
    required this.fileName,
    required this.type,
    required this.size,
    required this.createdAt,
  });

  factory RhDocument.fromJson(Map<String, dynamic> json) => RhDocument(
        id: json['id'] as String,
        name: json['name'] as String,
        fileName: json['fileName'] as String,
        type: DocumentTypeJson.fromJson(json['type'] as String),
        size: (json['size'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String name;
  final String fileName;
  final DocumentType type;
  final int size;
  final DateTime createdAt;

  String get formattedSize {
    if (size < 1024) return '$size o';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} Ko';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  String get formattedDate => formatDateDisplay(createdAt);
}
