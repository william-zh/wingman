enum ReportType {
  scammer,
  catfish,
  harassment,
  inappropriate,
  fakeProfile,
  financialFraud,
  emotionalManipulation,
  other
}

enum ReportSeverity {
  low,
  medium,
  high,
  critical
}

class SafetyReport {
  final String id;
  final String reportedUserId;
  final String reportedByUserId;
  final ReportType type;
  final ReportSeverity severity;
  final String description;
  final List<String> evidence;
  final DateTime createdAt;
  final bool isVerified;
  final int upvotes;
  final int downvotes;
  final Map<String, dynamic> metadata;

  SafetyReport({
    required this.id,
    required this.reportedUserId,
    required this.reportedByUserId,
    required this.type,
    required this.severity,
    required this.description,
    this.evidence = const [],
    required this.createdAt,
    this.isVerified = false,
    this.upvotes = 0,
    this.downvotes = 0,
    this.metadata = const {},
  });

  factory SafetyReport.fromJson(Map<String, dynamic> json) {
    return SafetyReport(
      id: json['id'],
      reportedUserId: json['reportedUserId'],
      reportedByUserId: json['reportedByUserId'],
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${json['type']}',
        orElse: () => ReportType.other,
      ),
      severity: ReportSeverity.values.firstWhere(
        (e) => e.toString() == 'ReportSeverity.${json['severity']}',
        orElse: () => ReportSeverity.low,
      ),
      description: json['description'],
      evidence: List<String>.from(json['evidence'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      isVerified: json['isVerified'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportedUserId': reportedUserId,
      'reportedByUserId': reportedByUserId,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'description': description,
      'evidence': evidence,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'metadata': metadata,
    };
  }
}

class CommunityWarning {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final int upvotes;
  final int views;
  final bool isAnonymous;

  CommunityWarning({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.createdAt,
    this.upvotes = 0,
    this.views = 0,
    this.isAnonymous = true,
  });

  factory CommunityWarning.fromJson(Map<String, dynamic> json) {
    return CommunityWarning(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      upvotes: json['upvotes'] ?? 0,
      views: json['views'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'upvotes': upvotes,
      'views': views,
      'isAnonymous': isAnonymous,
    };
  }
}