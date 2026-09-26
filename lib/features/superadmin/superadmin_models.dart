class SubscriptionInfo {
  SubscriptionInfo({
    required this.status,
    required this.tier,
    required this.licenseCount,
    required this.periodEnd,
    required this.autoRenew,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
        status: json['status'] as String,
        tier: json['tier'] as String,
        licenseCount: json['licenseCount'] as int? ?? 0,
        periodEnd: json['periodEnd'] as String?,
        autoRenew: json['autoRenew'] as bool? ?? false,
      );

  final String status;
  final String tier;
  final int licenseCount;
  final String? periodEnd;
  final bool autoRenew;
}

class CustomerAccount {
  CustomerAccount({
    required this.id,
    required this.name,
    required this.code,
    required this.adminEmail,
    required this.active,
    this.currentUserCount,
    this.maxUsers,
  });

  factory CustomerAccount.fromJson(Map<String, dynamic> json) => CustomerAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        adminEmail: json['adminEmail'] as String,
        active: json['active'] as bool? ?? true,
        currentUserCount: (json['currentUserCount'] as num?)?.toInt(),
        maxUsers: json['maxUsers'] as int?,
      );

  final String id;
  final String name;
  final String code;
  final String adminEmail;
  final bool active;
  final int? currentUserCount;
  final int? maxUsers;
}

class PromoCode {
  PromoCode({required this.id, required this.code, required this.discountAmountCents, required this.used, this.expiresAt});

  factory PromoCode.fromJson(Map<String, dynamic> json) => PromoCode(
        id: json['id'] as String,
        code: json['code'] as String,
        discountAmountCents: json['discountAmountCents'] as int,
        used: json['used'] as bool? ?? false,
        expiresAt: json['expiresAt'] as String?,
      );

  final String id;
  final String code;
  final int discountAmountCents;
  final bool used;
  final String? expiresAt;

  double get discountAmount => discountAmountCents / 100;
}
