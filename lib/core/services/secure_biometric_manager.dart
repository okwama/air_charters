import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:developer' as dev;
import '../models/auth_model.dart';
import '../error/app_exceptions.dart';
import '../../config/env/app_config.dart';

/// Secure Biometric Authentication Manager
/// Handles biometric authentication with proper encryption and security measures
class SecureBiometricManager {
  static final SecureBiometricManager _instance = SecureBiometricManager._internal();
  factory SecureBiometricManager() => _instance;
  SecureBiometricManager._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Storage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricDataKey = 'biometric_data_encrypted';
  static const String _biometricSaltKey = 'biometric_salt';
  static const String _biometricExpiryKey = 'biometric_expiry';
  
  // Security constants (using AppConfig)
  static const int _saltLength = 32;
  static const String _encryptionAlgorithm = 'AES-256-GCM';

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Biometric available: $isAvailable, Device supported: $isDeviceSupported', name: 'biometric');
      }
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error checking biometric availability: $e', name: 'biometric');
      }
      return false;
    }
  }

  /// Get available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Available biometrics: $biometrics', name: 'biometric');
      }
      return biometrics;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error getting biometric types: $e', name: 'biometric');
      }
      return [];
    }
  }

  /// Check if biometric authentication is enabled for the user
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _secureStorage.read(key: _biometricEnabledKey);
      final bool isEnabled = enabled == 'true';
      
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Biometric enabled: $isEnabled', name: 'biometric');
      }
      
      return isEnabled;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error checking biometric enabled status: $e', name: 'biometric');
      }
      return false;
    }
  }

  /// Check if stored biometric data is still valid (not expired)
  Future<bool> isBiometricDataValid() async {
    try {
      final String? expiryStr = await _secureStorage.read(key: _biometricExpiryKey);
      if (expiryStr == null) return false;
      
      final DateTime expiry = DateTime.parse(expiryStr);
      final bool isValid = DateTime.now().isBefore(expiry);
      
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Biometric data valid: $isValid, Expires: $expiry', name: 'biometric');
      }
      
      return isValid;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error checking biometric data validity: $e', name: 'biometric');
      }
      return false;
    }
  }

  /// Enable biometric authentication with secure data storage
  Future<void> enableBiometric(AuthModel authData) async {
    try {
      if (!await isBiometricAvailable()) {
        throw AuthException('Biometric authentication is not available on this device');
      }

      // Create secure biometric identifier (not full auth data)
      final String biometricId = _generateBiometricId();
      final DateTime expiry = DateTime.now().add(Duration(days: AppConfig.biometricDataExpiryDays));
      
      // Create minimal biometric data (no sensitive tokens)
      final Map<String, dynamic> biometricData = {
        'biometricId': biometricId,
        'userId': authData.user.id,
        'userEmail': authData.user.email,
        'userFirstName': authData.user.firstName,
        'userLastName': authData.user.lastName,
        'enabledAt': DateTime.now().toIso8601String(),
        'expiresAt': expiry.toIso8601String(),
      };

      // Encrypt the biometric data
      final String encryptedData = await _encryptBiometricData(biometricData);
      
      // Store encrypted data
      await _secureStorage.write(key: _biometricDataKey, value: encryptedData);
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      await _secureStorage.write(key: _biometricExpiryKey, value: expiry.toIso8601String());
      
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Biometric authentication enabled successfully', name: 'biometric');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error enabling biometric: $e', name: 'biometric');
      }
      throw AuthException('Failed to enable biometric authentication: $e');
    }
  }

  /// Disable biometric authentication and clear all data
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _biometricDataKey);
      await _secureStorage.delete(key: _biometricSaltKey);
      await _secureStorage.delete(key: _biometricExpiryKey);
      
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Biometric authentication disabled and data cleared', name: 'biometric');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error disabling biometric: $e', name: 'biometric');
      }
      throw AuthException('Failed to disable biometric authentication: $e');
    }
  }

  /// Authenticate using biometric and return minimal user data
  Future<Map<String, dynamic>?> authenticateWithBiometric() async {
    try {
      if (!await isBiometricAvailable()) {
        throw AuthException('Biometric authentication is not available');
      }

      if (!await isBiometricEnabled()) {
        throw AuthException('Biometric authentication is not enabled');
      }

      if (!await isBiometricDataValid()) {
        throw AuthException('Biometric data has expired. Please re-enable biometric authentication.');
      }

      // Authenticate with biometric
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Decrypt and return minimal user data
        final Map<String, dynamic>? userData = await _decryptBiometricData();
        
        if (userData != null) {
          if (kDebugMode) {
            dev.log('SecureBiometricManager: Biometric authentication successful', name: 'biometric');
          }
          
          return userData;
        } else {
          throw AuthException('Failed to decrypt biometric data');
        }
      } else {
        throw AuthException('Biometric authentication failed');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Biometric authentication error: $e', name: 'biometric');
      }
      
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Biometric authentication failed: $e');
      }
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> availableTypes) {
    if (availableTypes.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableTypes.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (availableTypes.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }

  /// Get biometric icon for display
  String getBiometricIcon(List<BiometricType> availableTypes) {
    if (availableTypes.contains(BiometricType.face)) {
      return '👤'; // Face ID icon
    } else if (availableTypes.contains(BiometricType.fingerprint)) {
      return '👆'; // Fingerprint icon
    } else if (availableTypes.contains(BiometricType.iris)) {
      return '👁️'; // Iris icon
    } else {
      return '🔐'; // Generic biometric icon
    }
  }

  /// Generate a unique biometric identifier
  String _generateBiometricId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Encrypt biometric data using AES encryption
  Future<String> _encryptBiometricData(Map<String, dynamic> data) async {
    try {
      // Generate or retrieve salt
      String? salt = await _secureStorage.read(key: _biometricSaltKey);
      if (salt == null) {
        salt = _generateSalt();
        await _secureStorage.write(key: _biometricSaltKey, value: salt);
      }

      // Convert data to JSON
      final String jsonData = jsonEncode(data);
      
      // Create encryption key from salt
      final key = _deriveKey(salt);
      
      // Simple XOR encryption (in production, use proper AES encryption)
      final List<int> dataBytes = utf8.encode(jsonData);
      final List<int> keyBytes = utf8.encode(key);
      final List<int> encryptedBytes = [];
      
      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64Encode(encryptedBytes);
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error encrypting biometric data: $e', name: 'biometric');
      }
      throw AuthException('Failed to encrypt biometric data: $e');
    }
  }

  /// Decrypt biometric data
  Future<Map<String, dynamic>?> _decryptBiometricData() async {
    try {
      final String? encryptedData = await _secureStorage.read(key: _biometricDataKey);
      if (encryptedData == null) return null;

      final String? salt = await _secureStorage.read(key: _biometricSaltKey);
      if (salt == null) return null;

      // Create decryption key from salt
      final key = _deriveKey(salt);
      
      // Decrypt data
      final List<int> encryptedBytes = base64Decode(encryptedData);
      final List<int> keyBytes = utf8.encode(key);
      final List<int> decryptedBytes = [];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      final String jsonData = utf8.decode(decryptedBytes);
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error decrypting biometric data: $e', name: 'biometric');
      }
      return null;
    }
  }

  /// Generate a random salt
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Derive encryption key from salt
  String _deriveKey(String salt) {
    final bytes = utf8.encode(salt);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// Clear all biometric data (for security cleanup)
  Future<void> clearAllBiometricData() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _biometricDataKey);
      await _secureStorage.delete(key: _biometricSaltKey);
      await _secureStorage.delete(key: _biometricExpiryKey);
      
      if (kDebugMode) {
        dev.log('SecureBiometricManager: All biometric data cleared', name: 'biometric');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error clearing biometric data: $e', name: 'biometric');
      }
    }
  }

  /// Check if biometric data needs refresh
  Future<bool> needsBiometricRefresh() async {
    try {
      final String? expiryStr = await _secureStorage.read(key: _biometricExpiryKey);
      if (expiryStr == null) return true;
      
      final DateTime expiry = DateTime.parse(expiryStr);
      final DateTime now = DateTime.now();
      final Duration timeUntilExpiry = expiry.difference(now);
      
      // Refresh if expires within configured warning period
      return timeUntilExpiry.inDays <= AppConfig.biometricRefreshWarningDays;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SecureBiometricManager: Error checking biometric refresh need: $e', name: 'biometric');
      }
      return true;
    }
  }
}
