import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';
import 'secure_biometric_manager.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SecureBiometricManager _secureManager = SecureBiometricManager();

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    return await _secureManager.isBiometricAvailable();
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _secureManager.getAvailableBiometrics();
  }

  // Check if biometric authentication is enabled for the user
  Future<bool> isBiometricEnabled() async {
    return await _secureManager.isBiometricEnabled();
  }

  // Enable biometric authentication for the user
  Future<void> enableBiometric(AuthModel authData) async {
    return await _secureManager.enableBiometric(authData);
  }

  // Disable biometric authentication
  Future<void> disableBiometric() async {
    return await _secureManager.disableBiometric();
  }

  // Authenticate using biometric
  Future<Map<String, dynamic>?> authenticateWithBiometric() async {
    return await _secureManager.authenticateWithBiometric();
  }

  // Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> availableTypes) {
    return _secureManager.getBiometricTypeName(availableTypes);
  }

  // Get biometric icon for display
  String getBiometricIcon(List<BiometricType> availableTypes) {
    return _secureManager.getBiometricIcon(availableTypes);
  }

  // Check if stored biometric data is still valid (not expired)
  Future<bool> isBiometricDataValid() async {
    return await _secureManager.isBiometricDataValid();
  }
}




