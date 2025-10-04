import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../config/env/app_config.dart';
import 'dart:developer' as dev;

/// Biometric Diagnostic Tool
/// Helps diagnose why biometric authentication cannot be enabled
class BiometricDiagnostic {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Run comprehensive biometric diagnostic
  static Future<BiometricDiagnosticResult> runDiagnostic(BuildContext context) async {
    final results = <String, dynamic>{};
    final issues = <String>[];
    final recommendations = <String>[];

    // 1. Check app configuration
    results['app_config_enabled'] = AppConfig.enableBiometricAuthentication;
    if (!AppConfig.enableBiometricAuthentication) {
      issues.add('Biometric authentication is disabled in app configuration');
      recommendations.add('Enable biometric authentication in AppConfig');
    }

    // 2. Check device support
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      results['device_supported'] = isDeviceSupported;
      if (!isDeviceSupported) {
        issues.add('Device does not support biometric authentication');
        recommendations.add('Use a device with biometric capabilities (fingerprint, face ID, etc.)');
      }
    } catch (e) {
      results['device_supported'] = false;
      issues.add('Error checking device support: $e');
    }

    // 3. Check biometric availability
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      results['can_check_biometrics'] = canCheckBiometrics;
      if (!canCheckBiometrics) {
        issues.add('Cannot check biometrics on this device');
        recommendations.add('Enable biometric authentication in device settings');
      }
    } catch (e) {
      results['can_check_biometrics'] = false;
      issues.add('Error checking biometric availability: $e');
    }

    // 4. Check available biometric types
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      results['available_biometrics'] = availableBiometrics.map((e) => e.toString()).toList();
      if (availableBiometrics.isEmpty) {
        issues.add('No biometric types are available');
        recommendations.add('Set up fingerprint or face ID in device settings');
      }
    } catch (e) {
      results['available_biometrics'] = [];
      issues.add('Error getting available biometrics: $e');
    }

    // 5. Check user authentication status
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      results['user_authenticated'] = authProvider.isAuthenticated;
      results['has_auth_data'] = authProvider.authData != null;
      
      if (!authProvider.isAuthenticated || authProvider.authData == null) {
        issues.add('User is not authenticated');
        recommendations.add('Please log in first to enable biometric authentication');
      }
    } catch (e) {
      results['user_authenticated'] = false;
      results['has_auth_data'] = false;
      issues.add('Error checking authentication status: $e');
    }

    // 6. Check current biometric status
    try {
      final isEnabled = await _secureStorage.read(key: 'biometric_enabled');
      results['biometric_enabled'] = isEnabled == 'true';
    } catch (e) {
      results['biometric_enabled'] = false;
      issues.add('Error checking biometric enabled status: $e');
    }

    // 7. Check secure storage availability
    try {
      await _secureStorage.write(key: 'test_key', value: 'test_value');
      await _secureStorage.delete(key: 'test_key');
      results['secure_storage_available'] = true;
    } catch (e) {
      results['secure_storage_available'] = false;
      issues.add('Secure storage is not available: $e');
      recommendations.add('Check device security settings and app permissions');
    }

    // 8. Test biometric authentication
    try {
      if (results['can_check_biometrics'] == true && 
          results['available_biometrics'] != null && 
          (results['available_biometrics'] as List).isNotEmpty) {
        // Note: This will show the biometric prompt, so we'll just check if it's possible
        results['biometric_test_available'] = true;
      } else {
        results['biometric_test_available'] = false;
      }
    } catch (e) {
      results['biometric_test_available'] = false;
      issues.add('Biometric test failed: $e');
    }

    return BiometricDiagnosticResult(
      results: results,
      issues: issues,
      recommendations: recommendations,
      canEnableBiometric: issues.isEmpty,
    );
  }

  /// Show diagnostic dialog
  static Future<void> showDiagnosticDialog(BuildContext context) async {
    final result = await runDiagnostic(context);
    
    showDialog(
      context: context,
      builder: (context) => BiometricDiagnosticDialog(result: result),
    );
  }
}

class BiometricDiagnosticResult {
  final Map<String, dynamic> results;
  final List<String> issues;
  final List<String> recommendations;
  final bool canEnableBiometric;

  BiometricDiagnosticResult({
    required this.results,
    required this.issues,
    required this.recommendations,
    required this.canEnableBiometric,
  });
}

class BiometricDiagnosticDialog extends StatelessWidget {
  final BiometricDiagnosticResult result;

  const BiometricDiagnosticDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Biometric Diagnostic'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.canEnableBiometric 
                    ? Colors.green.shade50 
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result.canEnableBiometric 
                      ? Colors.green.shade200 
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.canEnableBiometric 
                        ? Icons.check_circle 
                        : Icons.error,
                    color: result.canEnableBiometric 
                        ? Colors.green.shade600 
                        : Colors.red.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.canEnableBiometric 
                          ? 'Biometric authentication can be enabled'
                          : 'Issues found preventing biometric enablement',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: result.canEnableBiometric 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Text(
              'Diagnostic Results:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...result.results.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      color: entry.value == true 
                          ? Colors.green.shade600 
                          : entry.value == false 
                              ? Colors.red.shade600 
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )),

            if (result.issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Issues Found:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...result.issues.map((issue) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        issue,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            if (result.recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...result.recommendations.map((recommendation) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (result.canEnableBiometric)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to settings to enable biometric
              // This would typically be handled by the calling screen
            },
            child: const Text('Enable Biometric'),
          ),
      ],
    );
  }
}
