import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import 'dart:async';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isVerifyingCode = false;
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;
  String? _codeError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _codeVerified = false;

  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.requestPasswordReset(widget.email);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['success'] == true) {
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reset code sent successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();

    if (code.length != 6) {
      setState(() {
        _codeError = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _codeError = null;
    });

    try {
      final response = await _authService.verifyResetCode(widget.email, code);

      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });

        if (response['valid'] == true) {
          setState(() {
            _codeVerified = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code verified successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // Auto-focus password field
          _passwordFocus.requestFocus();
        } else {
          setState(() {
            _codeError = 'Invalid or expired code';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
          _codeError = 'Failed to verify code';
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final code = _codeControllers.map((c) => c.text).join();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    String? passwordError;
    String? confirmPasswordError;

    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
    } else if (password != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    if (passwordError != null || confirmPasswordError != null) {
      setState(() {
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    try {
      final response = await _authService.resetPassword(
        widget.email,
        code,
        password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['success'] == true) {
          // Show success and navigate to login
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _buildSuccessDialog(),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to reset password'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Password Reset Successful!',
              style: AppTheme.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your password has been reset successfully. You can now log in with your new password.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: Text(
                  'Go to Login',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: AppTheme.heading1.copyWith(
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to ${widget.email}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Code Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextFormField(
                        controller: _codeControllers[index],
                        focusNode: _codeFocusNodes[index],
                        enabled: !_isLoading && !_codeVerified,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTheme.heading2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _codeVerified
                                  ? AppTheme.successColor
                                  : AppTheme.borderColor,
                              width: _codeVerified ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.errorColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: _codeVerified
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.inputFillColor,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _codeFocusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _codeFocusNodes[index - 1].requestFocus();
                          }

                          // Auto-verify when all 6 digits entered
                          final code =
                              _codeControllers.map((c) => c.text).join();
                          if (code.length == 6 && !_codeVerified) {
                            _handleVerifyCode();
                          }

                          _clearError();
                        },
                      ),
                    );
                  }),
                ),

                if (_codeError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _codeError!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],

                if (_codeVerified) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Code verified successfully',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Resend code button
                Center(
                  child: TextButton(
                    onPressed:
                        _canResend && !_isLoading ? _handleResendCode : null,
                    child: Text(
                      _canResend ? 'Resend Code' : 'Resend in ${_resendTimer}s',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _canResend
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Divider(color: AppTheme.dividerColor),
                const SizedBox(height: 32),

                // New Password Section
                Text(
                  'New Password',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.next,
                  obscureText: !_passwordVisibility,
                  cursorColor: AppTheme.primaryColor,
                  enabled: !_isLoading && _codeVerified,
                  style: AppTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    hintText: 'Enter new password',
                    hintStyle: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.hintTextColor),
                    errorText: _passwordError,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    suffixIcon: InkWell(
                      onTap: () => setState(
                          () => _passwordVisibility = !_passwordVisibility),
                      child: Icon(
                        _passwordVisibility
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.errorColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppTheme.borderColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.inputFillColor,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.done,
                  obscureText: !_confirmPasswordVisibility,
                  cursorColor: AppTheme.primaryColor,
                  enabled: !_isLoading && _codeVerified,
                  style: AppTheme.bodyMedium,
                  onFieldSubmitted: (value) => _handleResetPassword(),
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    hintText: 'Re-enter new password',
                    hintStyle: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.hintTextColor),
                    errorText: _confirmPasswordError,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    suffixIcon: InkWell(
                      onTap: () => setState(() => _confirmPasswordVisibility =
                          !_confirmPasswordVisibility),
                      child: Icon(
                        _confirmPasswordVisibility
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.errorColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: AppTheme.borderColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.inputFillColor,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),

                // Reset Password Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (!_isLoading && _codeVerified)
                        ? _handleResetPassword
                        : null,
                    style: AppTheme.primaryButtonStyle,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Resetting...',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Reset Password',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Password must be at least 8 characters long and contain a mix of letters and numbers.',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearError() {
    if (_codeError != null) {
      setState(() {
        _codeError = null;
      });
    }
  }
}
