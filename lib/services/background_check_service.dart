import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/background_check.dart';

class BackgroundCheckService extends ChangeNotifier {
  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<BackgroundCheck> _recentChecks = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BackgroundCheck> get recentChecks => _recentChecks;

  BackgroundCheckService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'User-Agent': 'Wingman/1.0.0',
    };
  }

  Future<BackgroundCheck?> performBackgroundCheck({
    required String userId,
    required String phoneNumber,
    String? email,
    String? name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final checkId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final backgroundCheck = BackgroundCheck(
        id: checkId,
        userId: userId,
        targetPhoneNumber: phoneNumber,
        targetEmail: email,
        targetName: name,
        requestedAt: DateTime.now(),
        status: BackgroundCheckStatus.pending,
      );

      await _firestore
          .collection('background_checks')
          .doc(checkId)
          .set(backgroundCheck.toJson());

      final result = await _runBackgroundCheck(phoneNumber, email, name);
      
      final updatedCheck = backgroundCheck.copyWith(
        status: BackgroundCheckStatus.completed,
        completedAt: DateTime.now(),
        result: result,
      );

      await _firestore
          .collection('background_checks')
          .doc(checkId)
          .update(updatedCheck.toJson());

      await _loadRecentChecks(userId);
      
      return updatedCheck;
      
    } catch (e) {
      _errorMessage = 'Background check failed: $e';
      debugPrint('Background check error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BackgroundCheckResult> _runBackgroundCheck(
    String phoneNumber,
    String? email,
    String? name,
  ) async {
    final phoneInfo = await _checkPhoneNumber(phoneNumber);
    final socialProfiles = await _checkSocialMediaProfiles(phoneNumber, email, name);
    final criminalRecords = await _checkCriminalRecords(name, phoneNumber);
    final fraudHistory = await _checkFinancialFraud(phoneNumber, email);

    final riskScore = _calculateRiskScore(
      phoneInfo: phoneInfo,
      socialProfiles: socialProfiles,
      criminalRecords: criminalRecords,
      hasFinancialFraud: fraudHistory,
    );

    final riskFactors = _identifyRiskFactors(
      phoneInfo: phoneInfo,
      socialProfiles: socialProfiles,
      criminalRecords: criminalRecords,
      hasFinancialFraud: fraudHistory,
    );

    return BackgroundCheckResult(
      hasCriminalRecord: criminalRecords.isNotEmpty,
      isSexOffender: criminalRecords.any((r) => 
        r.offense.toLowerCase().contains('sex') || 
        r.offense.toLowerCase().contains('assault')),
      hasFinancialFraudHistory: fraudHistory,
      criminalRecords: criminalRecords,
      socialMediaProfiles: socialProfiles,
      phoneInfo: phoneInfo,
      riskScore: riskScore,
      riskFactors: riskFactors,
      generatedAt: DateTime.now(),
    );
  }

  Future<PhoneNumberInfo> _checkPhoneNumber(String phoneNumber) async {
    try {
      final response = await _dio.post(
        'https://api.wingman-safety.com/phone-lookup',
        data: {'phone': phoneNumber},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return PhoneNumberInfo(
          number: phoneNumber,
          carrier: data['carrier'] ?? 'Unknown',
          location: data['location'] ?? 'Unknown',
          type: data['type'] ?? 'Unknown',
          isValid: data['valid'] ?? false,
          isActive: data['active'] ?? false,
        );
      }
    } catch (e) {
      debugPrint('Phone lookup error: $e');
    }

    return PhoneNumberInfo(
      number: phoneNumber,
      carrier: 'Unknown',
      location: 'Unknown',
      type: 'Mobile',
      isValid: phoneNumber.length >= 10,
      isActive: true,
    );
  }

  Future<List<SocialMediaProfile>> _checkSocialMediaProfiles(
    String phoneNumber,
    String? email,
    String? name,
  ) async {
    final profiles = <SocialMediaProfile>[];
    
    try {
      final response = await _dio.post(
        'https://api.wingman-safety.com/social-lookup',
        data: {
          'phone': phoneNumber,
          if (email != null) 'email': email,
          if (name != null) 'name': name,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['profiles'] as List;
        for (final profile in data) {
          profiles.add(SocialMediaProfile(
            platform: profile['platform'],
            username: profile['username'],
            profileUrl: profile['url'],
            isVerified: profile['verified'] ?? false,
            followers: profile['followers'] ?? 0,
            lastActive: DateTime.parse(profile['lastActive']),
          ));
        }
      }
    } catch (e) {
      debugPrint('Social media lookup error: $e');
    }

    return profiles;
  }

  Future<List<CriminalRecord>> _checkCriminalRecords(
    String? name,
    String phoneNumber,
  ) async {
    final records = <CriminalRecord>[];
    
    if (name == null) return records;

    try {
      final response = await _dio.post(
        'https://api.wingman-safety.com/criminal-check',
        data: {
          'name': name,
          'phone': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['records'] as List;
        for (final record in data) {
          records.add(CriminalRecord(
            offense: record['offense'],
            severity: record['severity'],
            date: DateTime.parse(record['date']),
            location: record['location'],
            status: record['status'],
          ));
        }
      }
    } catch (e) {
      debugPrint('Criminal check error: $e');
    }

    return records;
  }

  Future<bool> _checkFinancialFraud(String phoneNumber, String? email) async {
    try {
      final response = await _dio.post(
        'https://api.wingman-safety.com/fraud-check',
        data: {
          'phone': phoneNumber,
          if (email != null) 'email': email,
        },
      );

      if (response.statusCode == 200) {
        return response.data['hasFraudHistory'] ?? false;
      }
    } catch (e) {
      debugPrint('Fraud check error: $e');
    }

    return false;
  }

  int _calculateRiskScore({
    required PhoneNumberInfo phoneInfo,
    required List<SocialMediaProfile> socialProfiles,
    required List<CriminalRecord> criminalRecords,
    required bool hasFinancialFraud,
  }) {
    int score = 0;

    if (!phoneInfo.isValid) score += 30;
    if (!phoneInfo.isActive) score += 20;
    if (phoneInfo.type == 'VOIP') score += 25;

    if (socialProfiles.isEmpty) {
      score += 40;
    } else {
      final verifiedProfiles = socialProfiles.where((p) => p.isVerified).length;
      if (verifiedProfiles == 0) score += 20;
    }

    score += criminalRecords.length * 25;
    if (hasFinancialFraud) score += 50;

    return score.clamp(0, 100);
  }

  List<String> _identifyRiskFactors({
    required PhoneNumberInfo phoneInfo,
    required List<SocialMediaProfile> socialProfiles,
    required List<CriminalRecord> criminalRecords,
    required bool hasFinancialFraud,
  }) {
    final factors = <String>[];

    if (!phoneInfo.isValid) factors.add('Invalid phone number');
    if (!phoneInfo.isActive) factors.add('Inactive phone number');
    if (phoneInfo.type == 'VOIP') factors.add('VOIP phone number');
    
    if (socialProfiles.isEmpty) {
      factors.add('No social media presence');
    } else {
      final verifiedProfiles = socialProfiles.where((p) => p.isVerified).length;
      if (verifiedProfiles == 0) factors.add('No verified social media accounts');
    }

    if (criminalRecords.isNotEmpty) {
      factors.add('Criminal history found');
      if (criminalRecords.any((r) => r.severity == 'High')) {
        factors.add('Serious criminal offenses');
      }
    }

    if (hasFinancialFraud) factors.add('Financial fraud history');

    return factors;
  }

  Future<void> _loadRecentChecks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('background_checks')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .limit(10)
          .get();

      _recentChecks = snapshot.docs
          .map((doc) => BackgroundCheck.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load recent checks: $e');
    }
  }

  Future<List<String>> reverseImageSearch(String imageUrl) async {
    try {
      final response = await _dio.post(
        'https://api.wingman-safety.com/reverse-image',
        data: {'imageUrl': imageUrl},
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data['matches'] ?? []);
      }
    } catch (e) {
      debugPrint('Reverse image search error: $e');
    }
    
    return [];
  }

  Future<bool> checkPhoneAgainstScammerDatabase(String phoneNumber) async {
    try {
      final response = await _dio.post(
        'https://api.wingman-safety.com/scammer-check',
        data: {'phone': phoneNumber},
      );

      if (response.statusCode == 200) {
        return response.data['isKnownScammer'] ?? false;
      }
    } catch (e) {
      debugPrint('Scammer database check error: $e');
    }
    
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}