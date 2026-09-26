enum ProspectStatus { aContacter, contacte, devisEnvoye, relance, transforme, perdu }

extension ProspectStatusJson on ProspectStatus {
  static const _apiNames = {
    ProspectStatus.aContacter: 'A_CONTACTER',
    ProspectStatus.contacte: 'CONTACTE',
    ProspectStatus.devisEnvoye: 'DEVIS_ENVOYE',
    ProspectStatus.relance: 'RELANCE',
    ProspectStatus.transforme: 'TRANSFORME',
    ProspectStatus.perdu: 'PERDU',
  };

  static const _labels = {
    ProspectStatus.aContacter: 'À contacter',
    ProspectStatus.contacte: 'Contacté',
    ProspectStatus.devisEnvoye: 'Devis envoyé',
    ProspectStatus.relance: 'Relance',
    ProspectStatus.transforme: 'Transformé',
    ProspectStatus.perdu: 'Perdu',
  };

  static ProspectStatus fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get apiName => _apiNames[this]!;

  String get label => _labels[this]!;
}

class ProspectComment {
  ProspectComment({required this.id, required this.text, required this.author, required this.createdAt});

  factory ProspectComment.fromJson(Map<String, dynamic> json) => ProspectComment(
        id: json['id'] as String,
        text: json['text'] as String,
        author: json['author'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String text;
  final String author;
  final DateTime createdAt;
}

class Prospect {
  Prospect({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.status,
    this.email,
    this.phone,
    this.city,
    this.comments = const [],
  });

  factory Prospect.fromJson(Map<String, dynamic> json) => Prospect(
        id: json['id'] as String,
        companyName: json['companyName'] as String,
        contactName: json['contactName'] as String,
        status: ProspectStatusJson.fromJson(json['status'] as String),
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        city: json['city'] as String?,
        comments: (json['comments'] as List<dynamic>? ?? [])
            .map((e) => ProspectComment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String companyName;
  final String contactName;
  final ProspectStatus status;
  final String? email;
  final String? phone;
  final String? city;
  final List<ProspectComment> comments;
}

enum DevisStatus { brouillon, envoye, accepte, refuse, aRelancer, transforme }

extension DevisStatusJson on DevisStatus {
  static const _apiNames = {
    DevisStatus.brouillon: 'BROUILLON',
    DevisStatus.envoye: 'ENVOYE',
    DevisStatus.accepte: 'ACCEPTE',
    DevisStatus.refuse: 'REFUSE',
    DevisStatus.aRelancer: 'A_RELANCER',
    DevisStatus.transforme: 'TRANSFORME',
  };

  static const _labels = {
    DevisStatus.brouillon: 'Brouillon',
    DevisStatus.envoye: 'Envoyé',
    DevisStatus.accepte: 'Accepté',
    DevisStatus.refuse: 'Refusé',
    DevisStatus.aRelancer: 'À relancer',
    DevisStatus.transforme: 'Transformé',
  };

  static DevisStatus fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get apiName => _apiNames[this]!;

  String get label => _labels[this]!;
}

class DevisLine {
  DevisLine({
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.taxRate,
  });

  factory DevisLine.fromJson(Map<String, dynamic> json) => DevisLine(
        description: json['description'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        taxRate: (json['taxRate'] as num).toDouble(),
      );

  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double taxRate;

  double get totalHt => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'taxRate': taxRate,
        'totalHt': totalHt,
      };
}

class Devis {
  Devis({
    required this.id,
    required this.devisNumber,
    required this.prospectName,
    required this.status,
    required this.lines,
    required this.totalHt,
    required this.taxAmount,
    required this.totalTtc,
  });

  factory Devis.fromJson(Map<String, dynamic> json) => Devis(
        id: json['id'] as String,
        devisNumber: json['devisNumber'] as String,
        prospectName: json['prospectName'] as String,
        status: DevisStatusJson.fromJson(json['status'] as String),
        lines: (json['lines'] as List<dynamic>? ?? []).map((e) => DevisLine.fromJson(e as Map<String, dynamic>)).toList(),
        totalHt: (json['totalHt'] as num).toDouble(),
        taxAmount: (json['taxAmount'] as num).toDouble(),
        totalTtc: (json['totalTtc'] as num).toDouble(),
      );

  final String id;
  final String devisNumber;
  final String prospectName;
  final DevisStatus status;
  final List<DevisLine> lines;
  final double totalHt;
  final double taxAmount;
  final double totalTtc;
}
