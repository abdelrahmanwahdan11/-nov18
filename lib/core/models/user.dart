class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.phone,
    required this.membershipLevel,
    required this.memberSince,
    required this.totalDistanceKm,
    required this.completedTrips,
    required this.ecoScore,
    required this.favoriteStations,
    required this.badges,
  });

  final String name;
  final String email;
  final String avatarUrl;
  final String phone;
  final String membershipLevel;
  final DateTime memberSince;
  final double totalDistanceKm;
  final int completedTrips;
  final double ecoScore;
  final List<String> favoriteStations;
  final List<String> badges;

  AppUser copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    String? membershipLevel,
    DateTime? memberSince,
    double? totalDistanceKm,
    int? completedTrips,
    double? ecoScore,
    List<String>? favoriteStations,
    List<String>? badges,
  }) {
    return AppUser(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      memberSince: memberSince ?? this.memberSince,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      completedTrips: completedTrips ?? this.completedTrips,
      ecoScore: ecoScore ?? this.ecoScore,
      favoriteStations: favoriteStations ?? this.favoriteStations,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'membershipLevel': membershipLevel,
      'memberSince': memberSince.toIso8601String(),
      'totalDistanceKm': totalDistanceKm,
      'completedTrips': completedTrips,
      'ecoScore': ecoScore,
      'favoriteStations': favoriteStations,
      'badges': badges,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['name'] as String? ?? 'Guest driver',
      email: json['email'] as String? ?? 'guest@evsmart.app',
      avatarUrl: json['avatarUrl'] as String? ?? _defaultAvatar,
      phone: json['phone'] as String? ?? '+000 0000 0000',
      membershipLevel: json['membershipLevel'] as String? ?? 'Explorer',
      memberSince: DateTime.tryParse(json['memberSince'] as String? ?? '') ??
          DateTime(2023, 1, 1),
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      ecoScore: (json['ecoScore'] as num?)?.toDouble() ?? 0,
      favoriteStations: (json['favoriteStations'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      badges:
          (json['badges'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  static AppUser guest() {
    return AppUser(
      name: 'Guest driver',
      email: 'guest@evsmart.app',
      avatarUrl: _defaultAvatar,
      phone: '+000 0000 0000',
      membershipLevel: 'Explorer',
      memberSince: DateTime(2023, 1, 1),
      totalDistanceKm: 0,
      completedTrips: 0,
      ecoScore: 0,
      favoriteStations: const [],
      badges: const ['Preview mode'],
    );
  }

  static const _defaultAvatar =
      'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=200&q=60';
}
