import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const String _privateKeyKey = 'encrypted_private_key';
  static const String _saltKey = 'encryption_salt';
  
  // In-memory storage for web (since flutter_secure_storage doesn't work reliably on web)
  static final Map<String, String> _memoryStorage = {};
  
  // Simple XOR encryption for demonstration (in production, use proper encryption)
  static Uint8List _encrypt(String data, String password) {
    final dataBytes = utf8.encode(data);
    final passwordBytes = utf8.encode(password);
    final encrypted = Uint8List(dataBytes.length);
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted[i] = dataBytes[i] ^ passwordBytes[i % passwordBytes.length];
    }
    
    return encrypted;
  }
  
  static String _decrypt(Uint8List encryptedData, String password) {
    final passwordBytes = utf8.encode(password);
    final decrypted = Uint8List(encryptedData.length);
    
    for (int i = 0; i < encryptedData.length; i++) {
      decrypted[i] = encryptedData[i] ^ passwordBytes[i % passwordBytes.length];
    }
    
    return utf8.decode(decrypted);
  }
  
  static String _generateSalt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = (timestamp.hashCode % 1000000).toString();
    return base64.encode(utf8.encode('$timestamp$random'));
  }
  
  static String _deriveKey(String password, String salt) {
    final combined = '$password$salt';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Store private key securely (encrypted in memory for web)
  static Future<bool> savePrivateKey(String privateKey, String password) async {
    try {
      if (kIsWeb) {
        // For web, store encrypted in memory only
        final salt = _generateSalt();
        final derivedKey = _deriveKey(password, salt);
        final encrypted = _encrypt(privateKey, derivedKey);
        
        _memoryStorage[_privateKeyKey] = base64.encode(encrypted);
        _memoryStorage[_saltKey] = salt;
        
        return true;
      } else {
        // For mobile/desktop, you would use flutter_secure_storage here
        // For now, we'll use the same in-memory approach
        final salt = _generateSalt();
        final derivedKey = _deriveKey(password, salt);
        final encrypted = _encrypt(privateKey, derivedKey);
        
        _memoryStorage[_privateKeyKey] = base64.encode(encrypted);
        _memoryStorage[_saltKey] = salt;
        
        return true;
      }
    } catch (e) {
      print('Error storing private key: $e');
      return false;
    }
  }

  /// Retrieve private key (decrypt from memory for web)
  static Future<String?> getPrivateKey(String password) async {
    try {
      if (kIsWeb) {
        // For web, retrieve from memory
        final encryptedBase64 = _memoryStorage[_privateKeyKey];
        final salt = _memoryStorage[_saltKey];
        
        if (encryptedBase64 == null || salt == null) {
          return null;
        }
        
        final encrypted = base64.decode(encryptedBase64);
        final derivedKey = _deriveKey(password, salt);
        final decrypted = _decrypt(encrypted, derivedKey);
        
        return decrypted;
      } else {
        // For mobile/desktop, you would use flutter_secure_storage here
        final encryptedBase64 = _memoryStorage[_privateKeyKey];
        final salt = _memoryStorage[_saltKey];
        
        if (encryptedBase64 == null || salt == null) {
          return null;
        }
        
        final encrypted = base64.decode(encryptedBase64);
        final derivedKey = _deriveKey(password, salt);
        final decrypted = _decrypt(encrypted, derivedKey);
        
        return decrypted;
      }
    } catch (e) {
      print('Error retrieving private key: $e');
      return null;
    }
  }

  /// Check if private key exists
  static Future<bool> hasPrivateKey() async {
    if (kIsWeb) {
      return _memoryStorage.containsKey(_privateKeyKey);
    } else {
      return _memoryStorage.containsKey(_privateKeyKey);
    }
  }

  /// Clear stored private key
  static Future<void> clearPrivateKey() async {
    if (kIsWeb) {
      _memoryStorage.remove(_privateKeyKey);
      _memoryStorage.remove(_saltKey);
    } else {
      _memoryStorage.remove(_privateKeyKey);
      _memoryStorage.remove(_saltKey);
    }
  }

  /// Validate password against stored private key
  static Future<bool> validatePassword(String password) async {
    try {
      final privateKey = await getPrivateKey(password);
      return privateKey != null;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    if (kIsWeb) {
      _memoryStorage.clear();
    } else {
      _memoryStorage.clear();
    }
  }

  /// Get storage info for debugging
  static Map<String, dynamic> getStorageInfo() {
    return {
      'platform': kIsWeb ? 'web' : 'native',
      'hasPrivateKey': _memoryStorage.containsKey(_privateKeyKey),
      'hasSalt': _memoryStorage.containsKey(_saltKey),
      'storageSize': _memoryStorage.length,
    };
  }
}


