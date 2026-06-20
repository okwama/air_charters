import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class EnableBiometricPage extends StatefulWidget {
  final String biometricName;
  final String biometricIcon;
  final bool isCurrentlyEnabled;

  const EnableBiometricPage({
    super.key,
    required this.biometricName,
    required this.biometricIcon,
    required this.isCurrentlyEnabled,
  });

  @override
  State<EnableBiometricPage> createState() => _EnableBiometricPageState();
}

class _EnableBiometricPageState extends State<EnableBiometricPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _confirmAndEnable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // ✅ This will trigger native biometric prompt
      await authProvider.enableBiometric();

      if (mounted) {
        // Success - go back and show success message
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.biometricName} enabled successfully!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _disable() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.disableBiometric();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.biometricName} disabled successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isCurrentlyEnabled
              ? 'Disable ${widget.biometricName}'
              : 'Enable ${widget.biometricName}',
          style: AppTheme.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Biometric Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isCurrentlyEnabled
                    ? Colors.red.shade50
                    : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isCurrentlyEnabled
                      ? Colors.red.shade200
                      : AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                widget.biometricIcon,
                style: const TextStyle(fontSize: 64),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              widget.isCurrentlyEnabled
                  ? '${widget.biometricName} is Active'
                  : 'Secure Your Account',
              style: AppTheme.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              widget.isCurrentlyEnabled
                  ? 'You can quickly login using ${widget.biometricName}. Disable to use password only.'
                  : 'Tap below to enable ${widget.biometricName}. You\'ll be asked to verify using ${widget.biometricName} to confirm it\'s you.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            if (!widget.isCurrentlyEnabled) ...[
              const SizedBox(height: 40),

              // Error message if any
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Enable Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmAndEnable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor:
                        AppTheme.primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Enable ${widget.biometricName}',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],

            if (widget.isCurrentlyEnabled) ...[
              const SizedBox(height: 32),

              // Disable Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _disable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    disabledBackgroundColor: Colors.red.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Disable ${widget.biometricName}',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Security Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isCurrentlyEnabled
                          ? 'Your biometric data is stored securely on your device and expires in 30 days.'
                          : 'You\'ll be prompted to use ${widget.biometricName} to confirm your identity and complete the setup.',
                      style: AppTheme.caption.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
