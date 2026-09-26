enum CandidateStatus { applied, inReview, phoneScreen, interview, offer, hired, rejected }

extension CandidateStatusJson on CandidateStatus {
  static const _apiNames = {
    CandidateStatus.applied: 'APPLIED',
    CandidateStatus.inReview: 'IN_REVIEW',
    CandidateStatus.phoneScreen: 'PHONE_SCREEN',
    CandidateStatus.interview: 'INTERVIEW',
    CandidateStatus.offer: 'OFFER',
    CandidateStatus.hired: 'HIRED',
    CandidateStatus.rejected: 'REJECTED',
  };

  static const _labels = {
    CandidateStatus.applied: 'Candidature reçue',
    CandidateStatus.inReview: 'En revue',
    CandidateStatus.phoneScreen: 'Pré-qualification',
    CandidateStatus.interview: 'Entretien',
    CandidateStatus.offer: 'Offre',
    CandidateStatus.hired: 'Recruté',
    CandidateStatus.rejected: 'Refusé',
  };

  static CandidateStatus fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get apiName => _apiNames[this]!;

  String get label => _labels[this]!;
}

class Candidate {
  Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.position,
    required this.status,
    this.phone,
    this.notes,
    this.hasCv = false,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        position: json['position'] as String,
        status: CandidateStatusJson.fromJson(json['status'] as String),
        phone: json['phone'] as String?,
        notes: json['notes'] as String?,
        hasCv: json['hasCv'] as bool? ?? false,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String position;
  final CandidateStatus status;
  final String? phone;
  final String? notes;
  final bool hasCv;

  String get fullName => '$firstName $lastName';
}
