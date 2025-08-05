class BackgroundCheck {
  final String id;
  final String userId;
  final String targetPhoneNumber;
  final String? targetEmail;
  final String? targetName;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final BackgroundCheckStatus status;
  final BackgroundCheckResult? result;
  final String? errorMessage;

  BackgroundCheck({
    required this.id,
    required this.userId,
    required this.targetPhoneNumber,
    this.targetEmail,
    this.targetName,
    required this.requestedAt,
    this.completedAt,
    required this.status,
    this.result,
    this.errorMessage,
  });

  factory BackgroundCheck.fromJson(Map<String, dynamic> json) {
    return BackgroundCheck(
      id: json['id'],
      userId: json['userId'],
      targetPhoneNumber: json['targetPhoneNumber'],
      targetEmail: json['targetEmail'],
      targetName: json['targetName'],
      requestedAt: DateTime.parse(json['requestedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      status: BackgroundCheckStatus.values.firstWhere(
        (e) => e.toString() == 'BackgroundCheckStatus.${json['status']}',
      ),
      result: json['result'] != null ? BackgroundCheckResult.fromJson(json['result']) : null,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetPhoneNumber': targetPhoneNumber,
      'targetEmail': targetEmail,
      'targetName': targetName,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'result': result?.toJson(),
      'errorMessage': errorMessage,
    };
  }

  BackgroundCheck copyWith({
    String? id,
    String? userId,
    String? targetPhoneNumber,
    String? targetEmail,
    String? targetName,
    DateTime? requestedAt,
    DateTime? completedAt,
    BackgroundCheckStatus? status,
    BackgroundCheckResult? result,
    String? errorMessage,
  }) {
    return BackgroundCheck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetPhoneNumber: targetPhoneNumber ?? this.targetPhoneNumber,
      targetEmail: targetEmail ?? this.targetEmail,
      targetName: targetName ?? this.targetName,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum BackgroundCheckStatus {
  pending,
  processing,
  completed,
  failed,
  expired
}

class BackgroundCheckResult {
  final bool hasCriminalRecord;
  final bool isSexOffender;
  final bool hasFinancialFraudHistory;
  final List<CriminalRecord> criminalRecords;
  final List<SocialMediaProfile> socialMediaProfiles;
  final PhoneNumberInfo phoneInfo;
  final int riskScore;
  final List<String> riskFactors;
  final DateTime generatedAt;

  BackgroundCheckResult({
    required this.hasCriminalRecord,
    required this.isSexOffender,
    required this.hasFinancialFraudHistory,
    this.criminalRecords = const [],
    this.socialMediaProfiles = const [],
    required this.phoneInfo,
    required this.riskScore,
    this.riskFactors = const [],
    required this.generatedAt,
  });

  factory BackgroundCheckResult.fromJson(Map<String, dynamic> json) {
    return BackgroundCheckResult(
      hasCriminalRecord: json['hasCriminalRecord'] ?? false,
      isSexOffender: json['isSexOffender'] ?? false,
      hasFinancialFraudHistory: json['hasFinancialFraudHistory'] ?? false,
      criminalRecords: (json['criminalRecords'] as List?)
          ?.map((e) => CriminalRecord.fromJson(e))
          .toList() ?? [],
      socialMediaProfiles: (json['socialMediaProfiles'] as List?)
          ?.map((e) => SocialMediaProfile.fromJson(e))
          .toList() ?? [],
      phoneInfo: PhoneNumberInfo.fromJson(json['phoneInfo']),
      riskScore: json['riskScore'] ?? 0,
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCriminalRecord': hasCriminalRecord,
      'isSexOffender': isSexOffender,
      'hasFinancialFraudHistory': hasFinancialFraudHistory,
      'criminalRecords': criminalRecords.map((e) => e.toJson()).toList(),
      'socialMediaProfiles': socialMediaProfiles.map((e) => e.toJson()).toList(),
      'phoneInfo': phoneInfo.toJson(),
      'riskScore': riskScore,
      'riskFactors': riskFactors,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

class CriminalRecord {
  final String offense;
  final String severity;
  final DateTime date;
  final String location;
  final String status;

  CriminalRecord({
    required this.offense,
    required this.severity,
    required this.date,
    required this.location,
    required this.status,
  });

  factory CriminalRecord.fromJson(Map<String, dynamic> json) {
    return CriminalRecord(
      offense: json['offense'],
      severity: json['severity'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offense': offense,
      'severity': severity,
      'date': date.toIso8601String(),
      'location': location,
      'status': status,
    };
  }
}

class SocialMediaProfile {
  final String platform;
  final String username;
  final String profileUrl;
  final bool isVerified;
  final int followers;
  final DateTime lastActive;

  SocialMediaProfile({
    required this.platform,
    required this.username,
    required this.profileUrl,
    required this.isVerified,
    required this.followers,
    required this.lastActive,
  });

  factory SocialMediaProfile.fromJson(Map<String, dynamic> json) {
    return SocialMediaProfile(
      platform: json['platform'],
      username: json['username'],
      profileUrl: json['profileUrl'],
      isVerified: json['isVerified'] ?? false,
      followers: json['followers'] ?? 0,
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'username': username,
      'profileUrl': profileUrl,
      'isVerified': isVerified,
      'followers': followers,
      'lastActive': lastActive.toIso8601String(),
    };
  }
}

class PhoneNumberInfo {
  final String number;
  final String carrier;
  final String location;
  final String type;
  final bool isValid;
  final bool isActive;

  PhoneNumberInfo({
    required this.number,
    required this.carrier,
    required this.location,
    required this.type,
    required this.isValid,
    required this.isActive,
  });

  factory PhoneNumberInfo.fromJson(Map<String, dynamic> json) {
    return PhoneNumberInfo(
      number: json['number'],
      carrier: json['carrier'],
      location: json['location'],
      type: json['type'],
      isValid: json['isValid'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'carrier': carrier,
      'location': location,
      'type': type,
      'isValid': isValid,
      'isActive': isActive,
    };
  }
}