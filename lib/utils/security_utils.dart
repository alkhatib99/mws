import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class SecurityUtils {
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  static const int _saltLength = 32; // 256 bits
  static const int _iterations = 100000; // PBKDF2 iterations

  /// Generate a cryptographically secure random salt
  static Uint8List generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  /// Generate a cryptographically secure random IV
  static Uint8List generateIV() {
    final random = Random.secure();
    final iv = Uint8List(_ivLength);
    for (int i = 0; i < _ivLength; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  /// Derive a key from password using PBKDF2
  static Uint8List deriveKey(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);
    
    // Simple PBKDF2 implementation
    Uint8List key = Uint8List(_keyLength);
    Uint8List u = Uint8List(32);
    Uint8List t = Uint8List(32);
    
    for (int i = 1; i <= (_keyLength / 32).ceil(); i++) {
      // U1 = HMAC(password, salt || i)
      final saltWithIndex = Uint8List(salt.length + 4);
      saltWithIndex.setRange(0, salt.length, salt);
      saltWithIndex[salt.length] = (i >> 24) & 0xff;
      saltWithIndex[salt.length + 1] = (i >> 16) & 0xff;
      saltWithIndex[salt.length + 2] = (i >> 8) & 0xff;
      saltWithIndex[salt.length + 3] = i & 0xff;
      
      final digest = hmac.convert(saltWithIndex);
      u.setRange(0, 32, digest.bytes);
      t.setRange(0, 32, u);
      
      // Ui = HMAC(password, Ui-1) for iterations
      for (int j = 1; j < _iterations; j++) {
        final nextDigest = hmac.convert(u);
        u.setRange(0, 32, nextDigest.bytes);
        
        // T = U1 XOR U2 XOR ... XOR Ui
        for (int k = 0; k < 32; k++) {
          t[k] ^= u[k];
        }
      }
      
      // Copy T to key
      final startIndex = (i - 1) * 32;
      final endIndex = min(startIndex + 32, _keyLength);
      key.setRange(startIndex, endIndex, t);
    }
    
    return key;
  }

  /// Simple XOR encryption (for demonstration - in production use AES)
  static Uint8List xorEncrypt(Uint8List data, Uint8List key) {
    final encrypted = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length];
    }
    return encrypted;
  }

  /// Simple XOR decryption
  static Uint8List xorDecrypt(Uint8List encryptedData, Uint8List key) {
    return xorEncrypt(encryptedData, key); // XOR is symmetric
  }

  /// Encrypt private key with password
  static Map<String, String> encryptPrivateKey(String privateKey, String password) {
    try {
      // Generate salt and IV
      final salt = generateSalt();
      final iv = generateIV();
      
      // Derive key from password
      final key = deriveKey(password, salt);
      
      // Convert private key to bytes
      final privateKeyBytes = utf8.encode(privateKey);
      
      // Encrypt using XOR (in production, use AES)
      final encryptedData = xorEncrypt(privateKeyBytes, key);
      
      // Combine IV and encrypted data
      final combined = Uint8List(iv.length + encryptedData.length);
      combined.setRange(0, iv.length, iv);
      combined.setRange(iv.length, combined.length, encryptedData);
      
      return {
        'encryptedData': base64.encode(combined),
        'salt': base64.encode(salt),
        'algorithm': 'XOR-PBKDF2',
        'iterations': _iterations.toString(),
      };
    } catch (e) {
      throw SecurityException('Failed to encrypt private key: $e');
    }
  }

  /// Decrypt private key with password
  static String decryptPrivateKey(Map<String, String> encryptedData, String password) {
    try {
      final algorithm = encryptedData['algorithm'];
      if (algorithm != 'XOR-PBKDF2') {
        throw SecurityException('Unsupported encryption algorithm: $algorithm');
      }
      
      // Decode salt and encrypted data
      final salt = base64.decode(encryptedData['salt']!);
      final combined = base64.decode(encryptedData['encryptedData']!);
      
      // Extract IV and encrypted data
      final iv = combined.sublist(0, _ivLength);
      final encrypted = combined.sublist(_ivLength);
      
      // Derive key from password
      final key = deriveKey(password, salt);
      
      // Decrypt data
      final decryptedBytes = xorDecrypt(encrypted, key);
      
      // Convert back to string
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw SecurityException('Failed to decrypt private key: $e');
    }
  }

  /// Validate Ethereum private key format
  static bool isValidPrivateKey(String privateKey) {
    try {
      // Remove 0x prefix if present
      String cleanKey = privateKey.toLowerCase();
      if (cleanKey.startsWith('0x')) {
        cleanKey = cleanKey.substring(2);
      }
      
      // Check length (64 hex characters = 32 bytes)
      if (cleanKey.length != 64) {
        return false;
      }
      
      // Check if all characters are valid hex
      final hexRegex = RegExp(r'^[0-9a-f]+$');
      if (!hexRegex.hasMatch(cleanKey)) {
        return false;
      }
      
      // Check if key is not zero
      final keyInt = BigInt.parse(cleanKey, radix: 16);
      if (keyInt == BigInt.zero) {
        return false;
      }
      
      // Check if key is within valid range for secp256k1
      final maxKey = BigInt.parse('fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140', radix: 16);
      if (keyInt >= maxKey) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate Ethereum address format
  static bool isValidEthereumAddress(String address) {
    try {
      // Remove 0x prefix if present
      String cleanAddress = address.toLowerCase();
      if (cleanAddress.startsWith('0x')) {
        cleanAddress = cleanAddress.substring(2);
      }
      
      // Check length (40 hex characters = 20 bytes)
      if (cleanAddress.length != 40) {
        return false;
      }
      
      // Check if all characters are valid hex
      final hexRegex = RegExp(r'^[0-9a-f]+$');
      return hexRegex.hasMatch(cleanAddress);
    } catch (e) {
      return false;
    }
  }

  /// Validate password strength
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.empty;
    }
    
    int score = 0;
    final checks = <String>[];
    
    // Length check
    if (password.length >= 8) {
      score += 1;
      checks.add('At least 8 characters');
    }
    
    if (password.length >= 12) {
      score += 1;
      checks.add('At least 12 characters');
    }
    
    // Character type checks
    if (RegExp(r'[a-z]').hasMatch(password)) {
      score += 1;
      checks.add('Lowercase letters');
    }
    
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score += 1;
      checks.add('Uppercase letters');
    }
    
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score += 1;
      checks.add('Numbers');
    }
    
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score += 1;
      checks.add('Special characters');
    }
    
    // No common patterns
    if (!RegExp(r'(123|abc|password|qwerty)', caseSensitive: false).hasMatch(password)) {
      score += 1;
      checks.add('No common patterns');
    }
    
    if (score <= 2) {
      return PasswordStrength.weak;
    } else if (score <= 4) {
      return PasswordStrength.medium;
    } else if (score <= 6) {
      return PasswordStrength.strong;
    } else {
      return PasswordStrength.veryStrong;
    }
  }

  /// Generate secure random password
  static String generateSecurePassword({int length = 16}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random.secure();
    
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Hash data using SHA-256
  static String hashSHA256(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data integrity using hash
  static bool verifyIntegrity(String data, String expectedHash) {
    final actualHash = hashSHA256(data);
    return actualHash == expectedHash;
  }

  /// Secure memory cleanup (best effort)
  static void secureCleanup(List<dynamic> sensitiveData) {
    for (final data in sensitiveData) {
      if (data is String) {
        // In Dart, strings are immutable, so we can't truly clear them
        // This is a limitation of the language
        if (kDebugMode) {
          print('Warning: Cannot securely clear string data in Dart');
        }
      } else if (data is Uint8List) {
        // Clear byte arrays
        data.fillRange(0, data.length, 0);
      } else if (data is List<int>) {
        // Clear integer lists
        data.fillRange(0, data.length, 0);
      }
    }
  }

  /// Check if running in secure context (HTTPS)
  static bool isSecureContext() {
    if (kIsWeb) {
      // On web, check if HTTPS
      return Uri.base.scheme == 'https' || Uri.base.host == 'localhost';
    }
    // On mobile/desktop, always considered secure
    return true;
  }

  /// Validate transaction amount
  static bool isValidAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value > 0 && value.isFinite;
    } catch (e) {
      return false;
    }
  }

  /// Sanitize input to prevent injection attacks
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'[<>"\'']'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'data:', caseSensitive: false), '')
        .trim();
  }

  /// Rate limiting helper
  static final Map<String, List<DateTime>> _rateLimitMap = {};
  
  static bool checkRateLimit(String key, {int maxRequests = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final requests = _rateLimitMap[key] ?? [];
    
    // Remove old requests outside the window
    requests.removeWhere((time) => now.difference(time) > window);
    
    // Check if limit exceeded
    if (requests.length >= maxRequests) {
      return false;
    }
    
    // Add current request
    requests.add(now);
    _rateLimitMap[key] = requests;
    
    return true;
  }

  /// Clear rate limit data
  static void clearRateLimitData() {
    _rateLimitMap.clear();
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
  veryStrong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get description {
    switch (this) {
      case PasswordStrength.empty:
        return 'Password required';
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.medium:
        return 'Medium strength';
      case PasswordStrength.strong:
        return 'Strong password';
      case PasswordStrength.veryStrong:
        return 'Very strong password';
    }
  }
  
  double get score {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}

class SecurityException implements Exception {
  final String message;
  
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}

