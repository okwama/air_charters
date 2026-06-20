import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/success_toast.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'package:air_charters/core/routes/app_routes.dart';
import 'widgets/biometric_setup_wizard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneEmailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _passwordVisibility = false;
  String _selectedCountryCode = '+254';
  String _selectedCountryFlag = '🇰🇪';
  bool _isEmailMode = false;

  String? _phoneEmailError;
  String? _passwordError;
  String? _generalError; // For network/server errors

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricIcon = '🔐';
  String _biometricName = 'Biometric';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.successMessage != null) {
        showSuccessToast(context, authProvider.successMessage!);
        authProvider.clear();
      }
      _checkBiometricAvailability();
    });
  }

  void _checkBiometricAvailability() async {
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

  @override
  void dispose() {
    _phoneEmailController.dispose();
    _passwordController.dispose();
    _phoneEmailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _clearFieldError(String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'phoneEmail':
          _phoneEmailError = null;
          break;
        case 'password':
          _passwordError = null;
          _generalError = null; // Clear general error when user types
          break;
      }
    });
  }

  void _handleSignInWithPassword() async {
    final phoneEmail = _phoneEmailController.text.trim();
    final password = _passwordController.text.trim();

    String? phoneEmailError;
    String? passwordError;

    if (phoneEmail.isEmpty) {
      phoneEmailError =
          _isEmailMode ? 'Email is required' : 'Phone number is required';
    } else if (_isEmailMode &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(phoneEmail)) {
      phoneEmailError = 'Please enter a valid email address';
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
    }

    if (phoneEmailError != null || passwordError != null) {
      setState(() {
        _phoneEmailError = phoneEmailError;
        _passwordError = passwordError;
      });
      return;
    }

    // Clear all errors before attempting login
    if (_phoneEmailError != null ||
        _passwordError != null ||
        _generalError != null) {
      setState(() {
        _phoneEmailError = null;
        _passwordError = null;
        _generalError = null;
      });
    }

    try {
      if (_isEmailMode) {
        print('🔐 LOGIN: Attempting email login for: $phoneEmail');
        await context
            .read<AuthProvider>()
            .signInWithEmail(phoneEmail, password);
      } else {
        final fullPhoneNumber = _formatPhoneNumber(phoneEmail);
        print('🔐 LOGIN: Attempting phone login for: $fullPhoneNumber');
        await context
            .read<AuthProvider>()
            .signInWithPhone(fullPhoneNumber, password);
      }
    } catch (e) {
      print('🔐 LOGIN: Exception caught: $e');
      // Error is handled by AuthProvider, we'll check it below
    }

    // Check result after login attempt
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      print('🔐 LOGIN: isAuthenticated = ${authProvider.isAuthenticated}');

      if (authProvider.isAuthenticated) {
        // Login successful
        if (authProvider.successMessage != null) {
          showSuccessToast(context, authProvider.successMessage!);
        }
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        _showBiometricSetupIfNeeded();
      } else {
        // Login failed - check for error
        print('🔐 LOGIN: Authentication failed - user not authenticated');

        if (authProvider.errorMessage != null) {
          print('🔐 LOGIN: Error message: ${authProvider.errorMessage}');
          _handleLoginError(authProvider.errorMessage!);
          // Clear the error from provider so it doesn't show in error widget
          authProvider.clearError();
        }
      }
    }
  }

  /// Categorize and display errors appropriately
  void _handleLoginError(String errorMessage) {
    final errorLower = errorMessage.toLowerCase();

    setState(() {
      // Check if it's an authentication error (invalid credentials)
      if (errorLower.contains('invalid') ||
          errorLower.contains('incorrect') ||
          errorLower.contains('wrong') ||
          errorLower.contains('not found') ||
          errorLower.contains('does not exist') ||
          errorLower.contains('authentication failed') ||
          errorLower.contains('unauthorized') ||
          errorLower.contains('credentials')) {
        // Show as inline password error
        _passwordError = 'Invalid email or password';
        _generalError = null;
      }
      // Check if it's a network error
      else if (errorLower.contains('network') ||
          errorLower.contains('connection') ||
          errorLower.contains('internet') ||
          errorLower.contains('socketexception') ||
          errorLower.contains('failed host lookup') ||
          errorLower.contains('timeout')) {
        // Show as general error below button
        _passwordError = null;
        _generalError = 'No internet connection. Please check your network.';
      }
      // Server errors
      else if (errorLower.contains('server') ||
          errorLower.contains('service') ||
          errorLower.contains('unavailable') ||
          errorLower.contains('500') ||
          errorLower.contains('503')) {
        _passwordError = null;
        _generalError = 'Service temporarily unavailable. Try again later.';
      }
      // Generic errors
      else {
        _passwordError = null;
        _generalError = 'Something went wrong. Please try again.';
      }
    });
  }

  void _selectCountry() async {
    final result =
        await Navigator.of(context).pushNamed(AppRoutes.countrySelection);
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedCountryCode = result['code'];
        _selectedCountryFlag = result['flag'];
      });
    }
  }

  void _toggleInputMode() {
    setState(() {
      _isEmailMode = !_isEmailMode;
      _clearFieldError('phoneEmail');
    });
  }

  String _formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }
    return _selectedCountryCode + cleanNumber;
  }

  void _handleBiometricLogin() async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.authenticateWithBiometric();
      if (mounted) {
        if (authProvider.isAuthenticated) {
          if (authProvider.successMessage != null) {
            showSuccessToast(context, authProvider.successMessage!);
          }
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.root, (route) => false);
        }
      }
    } catch (e) {
      // Error handled by AuthProvider
    }
  }

  void _showBiometricSetupIfNeeded() async {
    final authProvider = context.read<AuthProvider>();
    try {
      final isAvailable = await authProvider.isBiometricAvailable();
      final isEnabled = await authProvider.isBiometricEnabled();
      if (isAvailable && !isEnabled) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => BiometricSetupWizard(
                onComplete: () => Navigator.of(context).pop(),
                onSkip: () => Navigator.of(context).pop(),
              ),
            );
          }
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            // AirCharters Logo in styled box
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/logo/login.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // App Name
                            Text(
                              'AirCharters',
                              style: AppTheme.heading2.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Text(
                      'Welcome Back',
                      style: AppTheme.heading1.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to your account to continue',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Mode Toggle
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isEmailMode) _toggleInputMode();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: !_isEmailMode
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: 16,
                                      color: !_isEmailMode
                                          ? AppTheme.backgroundColor
                                          : AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Phone',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: !_isEmailMode
                                            ? AppTheme.backgroundColor
                                            : AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isEmailMode) _toggleInputMode();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _isEmailMode
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      size: 16,
                                      color: _isEmailMode
                                          ? AppTheme.backgroundColor
                                          : AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Email',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _isEmailMode
                                            ? AppTheme.backgroundColor
                                            : AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Phone/Email Input
                    if (!_isEmailMode) ...[
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _selectCountry,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.inputFillColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_selectedCountryFlag,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedCountryCode,
                                    style: AppTheme.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: AppTheme.textSecondaryColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneEmailController,
                              focusNode: _phoneEmailFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              cursorColor: AppTheme.primaryColor,
                              enabled: !authProvider.isLoading,
                              style: AppTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Phone number',
                                hintStyle: AppTheme.bodyMedium
                                    .copyWith(color: AppTheme.hintTextColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppTheme.borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppTheme.inputFillColor,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _phoneEmailController,
                        focusNode: _phoneEmailFocus,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: AppTheme.primaryColor,
                        enabled: !authProvider.isLoading,
                        style: AppTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          hintStyle: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.hintTextColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.inputFillColor,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      obscureText: !_passwordVisibility,
                      cursorColor: AppTheme.primaryColor,
                      enabled: !authProvider.isLoading,
                      style: AppTheme.bodyMedium,
                      onChanged: (value) => _clearFieldError('password'),
                      decoration: InputDecoration(
                        hintText: 'Password (required)',
                        hintStyle: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.hintTextColor),
                        errorText: _passwordError,
                        errorStyle: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _passwordError != null
                                ? AppTheme.errorColor
                                : AppTheme.borderColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _passwordError != null
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.errorColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.errorColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppTheme.inputFillColor,
                        contentPadding: const EdgeInsets.all(16),
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
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Biometric Login Button
                    if (_biometricAvailable && _biometricEnabled) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleBiometricLogin,
                          icon: Text(_biometricIcon,
                              style: const TextStyle(fontSize: 18)),
                          label: Text(
                            'Sign in with $_biometricName',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: AppTheme.secondaryButtonStyle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: AppTheme.dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: AppTheme.dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleSignInWithPassword,
                        style: AppTheme.primaryButtonStyle.copyWith(
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            // Keep orange color even when disabled (loading)
                            return AppTheme.primaryColor;
                          }),
                        ),
                        child: authProvider.isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.backgroundColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Signing In...',
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.backgroundColor,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Sign In',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.backgroundColor,
                                ),
                              ),
                      ),
                    ),

                    // Divider between Sign In and Browse as Guest
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.dividerColor)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // General Error Message (Network/Server errors)
                    if (_generalError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _generalError!,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Browse as Guest Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () {
                                authProvider.enterGuestMode();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/', (route) => false);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondaryColor,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: AppTheme.borderColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Browse as Guest',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bottom Section
                    Column(
                      children: [
                        TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => Navigator.of(context)
                                  .pushNamed(AppRoutes.forgotPassword),
                          child: Text(
                            'Forgot your password?',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : () => Navigator.of(context)
                                      .pushNamed(AppRoutes.signup),
                              child: Text(
                                'Sign Up',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
