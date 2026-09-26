class Client {
  Client({
    required this.id,
    required this.name,
    required this.active,
    this.email,
    this.phone,
    this.address,
    this.description,
    this.city,
    this.postalCode,
    this.country,
    this.siren,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'] as String,
        name: json['name'] as String,
        active: json['active'] as bool? ?? true,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        description: json['description'] as String?,
        city: json['city'] as String?,
        postalCode: json['postalCode'] as String?,
        country: json['country'] as String?,
        siren: json['siren'] as String?,
      );

  final String id;
  final String name;
  final bool active;
  final String? email;
  final String? phone;
  final String? address;
  final String? description;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? siren;

  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'description': description,
        'city': city,
        'postalCode': postalCode,
        'country': country,
      };
}
