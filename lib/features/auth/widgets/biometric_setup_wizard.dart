import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../shared/widgets/success_toast.dart';

/// Biometric Setup Wizard
/// Guides users through enabling biometric authentication
class BiometricSetupWizard extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const BiometricSetupWizard({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<BiometricSetupWizard> createState() => _BiometricSetupWizardState();
}

class _BiometricSetupWizardState extends State<BiometricSetupWizard> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricName = 'Biometric';
  String _biometricIcon = '🔐';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      final isAvailable = await authProvider.isBiometricAvailable();
      final isEnabled = await authProvider.isBiometricEnabled();
      final availableTypes = await authProvider.getAvailableBiometrics();
      
      if (mounted) {
        setState(() {
          _biometricAvailable = isAvailable;
          _biometricEnabled = isEnabled;
          if (isAvailable && availableTypes.isNotEmpty) {
            _biometricName = authProvider.getBiometricTypeName(availableTypes);
            _biometricIcon = authProvider.getBiometricIcon(availableTypes);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _biometricEnabled = false;
        });
      }
    }
  }

  Future<void> _enableBiometric() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.enableBiometric();
      
      if (mounted) {
        setState(() {
          _biometricEnabled = true;
          _currentStep = 2; // Move to success step
        });
        
        showSuccessToast(context, 'Biometric authentication enabled successfully!');
        
        // Call completion callback after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onComplete?.call();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to enable biometric authentication: $e',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipSetup() {
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _biometricIcon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable $_biometricName',
                          style: AppTheme.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Secure and convenient login',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Step indicator
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index < 2 ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Step content
                  _buildStepContent(),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      if (_currentStep < 2) ...[
                        Expanded(
                          child: TextButton(
                            onPressed: _skipSetup,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textSecondaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Skip',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getButtonAction(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _getButtonText(),
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildIntroductionStep();
      case 1:
        return _buildSetupStep();
      case 2:
        return _buildSuccessStep();
      default:
        return _buildIntroductionStep();
    }
  }

  Widget _buildIntroductionStep() {
    return Column(
      children: [
        Icon(
          Icons.security,
          size: 64,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Secure Your Account',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Use $_biometricName to quickly and securely access your account without typing your password.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your biometric data is encrypted and stored securely on your device',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetupStep() {
    if (!_biometricAvailable) {
      return Column(
        children: [
          Icon(
            Icons.warning,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Biometric Not Available',
            style: AppTheme.heading3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your device doesn\'t support biometric authentication or it\'s not set up.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          _biometricIcon,
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 24),
        Text(
          'Enable $_biometricName',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap the button below to enable $_biometricName authentication. You\'ll be prompted to authenticate.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can always change this setting later in your account preferences.',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: 64,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          'All Set!',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$_biometricName authentication is now enabled. You can use it to quickly access your account.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your account is now more secure with biometric authentication.',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getButtonText() {
    if (_isLoading) return 'Setting up...';
    
    switch (_currentStep) {
      case 0:
        return 'Continue';
      case 1:
        if (!_biometricAvailable) return 'Skip';
        return 'Enable $_biometricName';
      case 2:
        return 'Done';
      default:
        return 'Continue';
    }
  }

  VoidCallback? _getButtonAction() {
    if (_isLoading) return null;
    
    switch (_currentStep) {
      case 0:
        return () {
          setState(() {
            _currentStep = 1;
          });
        };
      case 1:
        if (!_biometricAvailable) return _skipSetup;
        return _enableBiometric;
      case 2:
        return () {
          Navigator.of(context).pop();
          widget.onComplete?.call();
        };
      default:
        return null;
    }
  }
}
