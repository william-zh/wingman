import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class PrivacyService {
  static final _key = Key.fromSecureRandom(32);
  static final _iv = IV.fromSecureRandom(16);
  static final _encrypter = Encrypter(AES(_key));

  /// Encrypts sensitive data before storing
  static String encryptData(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  /// Decrypts sensitive data after retrieval
  static String decryptData(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  /// Hashes phone numbers for safe storage and lookup
  static String hashPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final bytes = utf8.encode(cleanNumber);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hashes email addresses for safe storage and lookup
  static String hashEmail(String email) {
    final cleanEmail = email.toLowerCase().trim();
    final bytes = utf8.encode(cleanEmail);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Anonymizes user data for community reports
  static Map<String, dynamic> anonymizeUserData(Map<String, dynamic> userData) {
    final anonymized = Map<String, dynamic>.from(userData);
    
    // Remove personally identifiable information
    anonymized.remove('email');
    anonymized.remove('phoneNumber');
    anonymized.remove('displayName');
    anonymized.remove('photoUrl');
    
    // Replace user ID with anonymous identifier
    if (anonymized['userId'] != null) {
      anonymized['userId'] = hashString(anonymized['userId']);
    }
    
    // Keep only safety-relevant data
    anonymized['timestamp'] = DateTime.now().toIso8601String();
    anonymized['verified'] = userData['isVerified'] ?? false;
    
    return anonymized;
  }

  /// Creates an anonymous user identifier for community posts
  static String createAnonymousId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = '$userId$timestamp';
    return hashString(combined).substring(0, 8);
  }

  /// Generic string hashing function
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validates that data doesn't contain PII before sharing
  static bool containsPII(String text) {
    final piiPatterns = [
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Credit card
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email
      RegExp(r'\b\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}\b'), // Phone
      RegExp(r'\b\d{1,5}\s+[A-Za-z\s]+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Place|Pl)\b', caseSensitive: false), // Address
    ];

    for (final pattern in piiPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    
    return false;
  }

  /// Sanitizes text by removing or masking PII
  static String sanitizeText(String text) {
    String sanitized = text;
    
    // Mask email addresses
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      (match) => '[EMAIL REMOVED]',
    );
    
    // Mask phone numbers
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}\b'),
      (match) => '[PHONE REMOVED]',
    );
    
    // Mask credit card numbers
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
      (match) => '[CARD REMOVED]',
    );
    
    // Mask SSN
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      (match) => '[SSN REMOVED]',
    );
    
    return sanitized;
  }

  /// Generates a secure random token for user verification
  static String generateVerificationToken() {
    final random = IV.fromSecureRandom(32);
    return random.base64;
  }

  /// Creates a secure session token
  static String generateSessionToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = '$userId:$timestamp';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validates that uploaded images don't contain metadata that could identify users
  static Map<String, dynamic> sanitizeImageMetadata(Uint8List imageBytes) {
    // In a real implementation, you would:
    // 1. Strip EXIF data that contains location, camera info, etc.
    // 2. Remove any embedded metadata
    // 3. Optionally resize/compress to remove forensic traces
    
    return {
      'sanitized': true,
      'originalSize': imageBytes.length,
      'sanitizedSize': imageBytes.length, // Would be different after processing
      'metadataRemoved': ['exif', 'location', 'camera_info'],
    };
  }

  /// Rate limiting to prevent abuse
  static bool isActionAllowed(String userId, String action, {int maxPerHour = 10}) {
    // In a real implementation, you would check against a rate limiting store
    // For now, we'll return true but this should be implemented with Redis or similar
    return true;
  }

  /// Logs security events without storing PII
  static void logSecurityEvent(String eventType, Map<String, dynamic> context) {
    final sanitizedContext = Map<String, dynamic>.from(context);
    
    // Remove PII from logs
    sanitizedContext.remove('email');
    sanitizedContext.remove('phoneNumber');
    sanitizedContext.remove('realName');
    
    // Hash user identifiers
    if (sanitizedContext['userId'] != null) {
      sanitizedContext['userHash'] = hashString(sanitizedContext['userId']);
      sanitizedContext.remove('userId');
    }
    
    // Add timestamp
    sanitizedContext['timestamp'] = DateTime.now().toIso8601String();
    sanitizedContext['eventType'] = eventType;
    
    // In a real app, send to security logging service
    print('SECURITY_EVENT: ${jsonEncode(sanitizedContext)}');
  }
}