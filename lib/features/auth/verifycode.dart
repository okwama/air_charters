import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/custom_button.dart';
import 'package:air_charters/shared/widgets/app_spinner.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, this.phoneNumber});
  final String? phoneNumber;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onCodeChanged(int idx, String value) {
    if (value.length == 1 && idx < 5) {
      _focusNodes[idx + 1].requestFocus();
    } else if (value.isEmpty && idx > 0) {
      _focusNodes[idx - 1].requestFocus();
    }
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    if (_code.length != 6) {
      _showErrorSnackBar('Please enter the 6-digit code.');
      return;
    }

    try {
      final phoneNumber = widget.phoneNumber;
      if (phoneNumber == null) {
        _showErrorSnackBar('Phone number not available for verification.');
        return;
      }

      await context.read<AuthProvider>().verifyPhoneCode(phoneNumber, _code);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  Future<void> _resendCode() async {
    final phoneNumber = widget.phoneNumber;
    if (phoneNumber == null) {
      _showErrorSnackBar('Phone number not available for resend.');
      return;
    }

    try {
      await context.read<AuthProvider>().sendPhoneVerification(phoneNumber);
      _startTimer();
      _showSuccessSnackBar('Verification code resent successfully.');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phoneNumber ?? 'your phone number';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            'Welcome!',
                            style: GoogleFonts.interTight(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter the 6-digit code sent to you at $phone',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (idx) {
                              return SizedBox(
                                width: 48,
                                child: TextField(
                                  controller: _controllers[idx],
                                  focusNode: _focusNodes[idx],
                                  autofocus: idx == 0,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  enabled: !authProvider.isLoading,
                                  style: GoogleFonts.interTight(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: AppTheme.borderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: AppTheme.borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 19, 18, 18)),
                                    ),
                                  ),
                                  onChanged: (v) => _onCodeChanged(idx, v),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          _canResend
                              ? TextButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _resendCode,
                                  child: Text(
                                    'Resend code',
                                    style: GoogleFonts.inter(
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                        ],
                      ),
                      Column(
                        children: [
                          // Error message
                          if (authProvider.errorMessage != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                authProvider.errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.red.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Back',
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  isOutlined: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  text: 'Next',
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _verifyCode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Loading overlay
                if (authProvider.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: AppSpinner(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
