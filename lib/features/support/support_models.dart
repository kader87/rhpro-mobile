enum SupportMessageStatus { new_, read, answered, closed }

extension SupportMessageStatusJson on SupportMessageStatus {
  static const _apiNames = {
    SupportMessageStatus.new_: 'NEW',
    SupportMessageStatus.read: 'READ',
    SupportMessageStatus.answered: 'ANSWERED',
    SupportMessageStatus.closed: 'CLOSED',
  };

  static SupportMessageStatus fromJson(String value) =>
      _apiNames.entries.firstWhere((e) => e.value == value, orElse: () => _apiNames.entries.first).key;

  String get label => switch (this) {
        SupportMessageStatus.new_ => 'Nouveau',
        SupportMessageStatus.read => 'Lu',
        SupportMessageStatus.answered => 'Répondu',
        SupportMessageStatus.closed => 'Fermé',
      };
}

class SupportMessage {
  SupportMessage({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    this.senderName,
    this.reply,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
        id: json['id'] as String,
        subject: json['subject'] as String,
        message: json['message'] as String,
        status: SupportMessageStatusJson.fromJson(json['status'] as String),
        senderName: json['senderName'] as String?,
        reply: json['reply'] as String?,
      );

  final String id;
  final String subject;
  final String message;
  final SupportMessageStatus status;
  final String? senderName;
  final String? reply;
}
