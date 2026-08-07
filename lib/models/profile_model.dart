// profile_model.dart
// Model data untuk profil pengguna (User Profile), termasuk preferensi
// seperti currency, timezone, dan locale, serta konversi ke/dari JSON.

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String currency;
  final String timezone;
  final String locale;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSeen;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.currency = 'IDR',
    this.timezone = 'Asia/Jakarta',
    this.locale = 'en',
    this.createdAt,
    this.updatedAt,
    this.lastSeen,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      currency: json['currency']?.toString() ?? 'IDR',
      timezone: json['timezone']?.toString() ?? 'Asia/Jakarta',
      locale: json['locale']?.toString() ?? 'en',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'].toString())
          : null,
    );
  }

  /// Serialisasi ke body request PATCH /users/me
  Map<String, dynamic> toRequestJson() => {
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'currency': currency,
        'timezone': timezone,
        'locale': locale,
      };

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? currency,
    String? timezone,
    String? locale,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}