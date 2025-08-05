class WingmanUser {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isIdVerified;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> verificationBadges;
  final int safetyScore;
  final List<String> reportedByUsers;

  WingmanUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.isIdVerified = false,
    required this.createdAt,
    required this.lastActiveAt,
    this.verificationBadges = const {},
    this.safetyScore = 0,
    this.reportedByUsers = const [],
  });

  factory WingmanUser.fromJson(Map<String, dynamic> json) {
    return WingmanUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      isVerified: json['isVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isIdVerified: json['isIdVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: DateTime.parse(json['lastActiveAt']),
      verificationBadges: Map<String, dynamic>.from(json['verificationBadges'] ?? {}),
      safetyScore: json['safetyScore'] ?? 0,
      reportedByUsers: List<String>.from(json['reportedByUsers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'isIdVerified': isIdVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'verificationBadges': verificationBadges,
      'safetyScore': safetyScore,
      'reportedByUsers': reportedByUsers,
    };
  }

  WingmanUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? isIdVerified,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? verificationBadges,
    int? safetyScore,
    List<String>? reportedByUsers,
  }) {
    return WingmanUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isIdVerified: isIdVerified ?? this.isIdVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      verificationBadges: verificationBadges ?? this.verificationBadges,
      safetyScore: safetyScore ?? this.safetyScore,
      reportedByUsers: reportedByUsers ?? this.reportedByUsers,
    );
  }
}