import 'package:air_charters/features/auth/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/success_toast.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'package:air_charters/core/routes/app_routes.dart';
import 'package:air_charters/shared/widgets/network_error_widget.dart';
import 'dart:developer' as dev;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Form Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;
  final ApiClient _apiClient = ApiClient();

  // Phone number settings
  String _selectedCountryCode = '+254'; // Default to Kenya
  String _selectedCountryFlag = '🇰🇪';

  // Form validation errors
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style:
                AppTheme.bodyMedium.copyWith(color: AppTheme.backgroundColor)),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleSignUpWithEmail() async {
    print('🔥 SIGNUP SCREEN: _handleSignUpWithEmail CALLED 🔥');
    dev.log('=== SIGNUP SCREEN: _handleSignUpWithEmail CALLED ===',
        name: 'SignupScreen-DEBUG');

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Quick validation without setState to avoid flickering
    String? firstNameError;
    String? lastNameError;
    String? emailError;
    String? phoneError;
    String? passwordError;
    String? confirmPasswordError;

    // Validate first name
    if (firstName.isEmpty) {
      firstNameError = 'First name is required';
    }

    // Validate last name
    if (lastName.isEmpty) {
      lastNameError = 'Last name is required';
    }

    // Validate email
    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError = 'Please enter a valid email address';
    }

    // Validate phone number (optional)
    if (phone.isNotEmpty) {
      // Remove leading 0 and format
      String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }

      // Check if it's a valid phone number (7-12 digits)
      final digitsOnly = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 7 || digitsOnly.length > 12) {
        phoneError = 'Please enter a valid phone number';
      }
    }

    // Validate password
    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
    } else if (password != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    // Only show validation errors if there are any
    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      setState(() {
        _firstNameError = firstNameError;
        _lastNameError = lastNameError;
        _emailError = emailError;
        _phoneError = phoneError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      dev.log('Form validation failed - showing field errors',
          name: 'SignupScreen-WARNING');
      return;
    }

    // Clear any existing errors before proceeding
    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      setState(() {
        _firstNameError = null;
        _lastNameError = null;
        _emailError = null;
        _passwordError = null;
        _confirmPasswordError = null;
      });
    }

    dev.log(
        'Form data: firstName=$firstName, lastName=$lastName, email=$email, password=${password.isNotEmpty ? "***" : "empty"}',
        name: 'SignupScreen-DEBUG');

    dev.log(
      'Attempting to sign up with email: $email, name: $firstName $lastName',
      name: 'SignupScreen',
    );

    try {
      // Check if user already exists
      final authProvider = context.read<AuthProvider>();
      final userExists = await authProvider.checkUserExists(email);

      if (userExists) {
        _showErrorSnackBar(
            'An account with this email already exists. Please try logging in instead.');
        return;
      }

      dev.log('About to call authProvider.signUpWithEmail',
          name: 'SignupScreen-DEBUG');

      // Format phone number if provided
      String? formattedPhone;
      if (phone.isNotEmpty) {
        formattedPhone = _formatPhoneNumber(phone);
      }

      await authProvider.signUpWithEmail(email, password, firstName, lastName,
          phoneNumber: formattedPhone);
      dev.log('authProvider.signUpWithEmail completed',
          name: 'SignupScreen-DEBUG');

      if (mounted) {
        dev.log(
            'Checking if user is authenticated: ${authProvider.isAuthenticated}',
            name: 'SignupScreen-DEBUG');
        if (authProvider.isAuthenticated) {
          dev.log('User is authenticated, navigating to home',
              name: 'SignupScreen-DEBUG');
          if (authProvider.successMessage != null) {
            showSuccessToast(context, authProvider.successMessage!);
          }
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.root, (route) => false);
        } else {
          dev.log('User is NOT authenticated after signup',
              name: 'SignupScreen-WARNING');
        }
      }
    } catch (e) {
      if (mounted) {
        dev.log('Signup error: $e', name: 'SignupScreen-ERROR');
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _clearFieldError(String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'firstName':
          _firstNameError = null;
          break;
        case 'lastName':
          _lastNameError = null;
          break;
        case 'email':
          _emailError = null;
          break;
        case 'phone':
          _phoneError = null;
          break;
        case 'password':
          _passwordError = null;
          break;
        case 'confirmPassword':
          _confirmPasswordError = null;
          break;
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

  String _formatPhoneNumber(String phoneNumber) {
    // Remove any spaces, dashes, or parentheses
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Remove leading 0 if present (Kenya format: 0706166875 -> 706166875)
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    // Combine with country code
    return _selectedCountryCode + cleanNumber;
  }

  void _validateForm() {
    setState(() {
      // Clear previous errors
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      // Validate first name
      if (_firstNameController.text.trim().isEmpty) {
        _firstNameError = 'First name is required';
      }

      // Validate last name
      if (_lastNameController.text.trim().isEmpty) {
        _lastNameError = 'Last name is required';
      }

      // Validate email
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Please enter a valid email address';
      }

      // Validate password
      final password = _passwordController.text.trim();
      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      // Validate confirm password
      final confirmPassword = _confirmPasswordController.text.trim();
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (password != confirmPassword) {
        _confirmPasswordError = 'Passwords do not match';
      }
    });
  }

  bool _isFormValid() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty &&
        _firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  void _testBackendConnection() async {
    try {
      dev.log('Testing backend connection from signup screen',
          name: 'SignupScreen');
      final isHealthy = await _apiClient.checkBackendHealth();
      dev.log('Backend health check result: $isHealthy', name: 'SignupScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHealthy ? '✅ Backend is reachable!' : '❌ Backend not reachable',
              style:
                  AppTheme.bodyMedium.copyWith(color: AppTheme.backgroundColor),
            ),
            backgroundColor:
                isHealthy ? AppTheme.successColor : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      dev.log('Backend test error: $e', name: 'SignupScreen-ERROR');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Backend test failed: $e',
              style:
                  AppTheme.bodyMedium.copyWith(color: AppTheme.backgroundColor),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
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
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // More spacious Header
                        Text(
                          'Create Account',
                          style: AppTheme.heading1
                              .copyWith(fontSize: 32, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your journey with us today.',
                          style: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.textSecondaryColor),
                        ),
                        const SizedBox(height: 40),

                        // Signup Form
                        _buildEmailForm(authProvider),

                        const SizedBox(height: 32),

                        // Login Link
                        _buildLoginLink(authProvider),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(AuthProvider authProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration(
                  hintText: 'First Name',
                  errorText: _firstNameError,
                ),
                enabled: !authProvider.isLoading,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => _clearFieldError('firstName'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration(
                  hintText: 'Last Name',
                  errorText: _lastNameError,
                ),
                enabled: !authProvider.isLoading,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => _clearFieldError('lastName'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hintText: 'Email address',
            errorText: _emailError,
          ),
          enabled: !authProvider.isLoading,
          onChanged: (value) => _clearFieldError('email'),
        ),
        const SizedBox(height: 16),

        // Phone Number Field with Country Code
        Row(
          children: [
            // Country Code Selector
            GestureDetector(
              onTap: _selectCountry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(14),
                  color: AppTheme.backgroundColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountryFlag,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCountryCode,
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textPrimaryColor),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  hintText: 'Phone number (optional)',
                  errorText: _phoneError,
                ),
                enabled: !authProvider.isLoading,
                onChanged: (value) => _clearFieldError('phone'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisibility,
          decoration: _inputDecoration(
            hintText: 'Password',
            errorText: _passwordError,
            suffixIcon: InkWell(
              onTap: () =>
                  setState(() => _passwordVisibility = !_passwordVisibility),
              child: Icon(
                  _passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textPrimaryColor,
                  size: 20),
            ),
          ),
          enabled: !authProvider.isLoading,
          onChanged: (value) => _clearFieldError('password'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_confirmPasswordVisibility,
          decoration: _inputDecoration(
            hintText: 'Confirm Password',
            errorText: _confirmPasswordError,
            suffixIcon: InkWell(
              onTap: () => setState(() =>
                  _confirmPasswordVisibility = !_confirmPasswordVisibility),
              child: Icon(
                  _confirmPasswordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textPrimaryColor,
                  size: 20),
            ),
          ),
          enabled: !authProvider.isLoading,
          onChanged: (value) => _clearFieldError('confirmPassword'),
        ),
        const SizedBox(height: 20),

        // More spacious Error message
        if (authProvider.errorMessage != null) ...[
          QuickNetworkErrorWidget(
            error: authProvider.errorMessage,
            onRetry: () {
              // Clear error and retry signup
              authProvider.clearError();
            },
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleSignUpWithEmail,
            style: AppTheme.primaryButtonStyle,
            child: authProvider.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
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
                        'Creating Account...',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.backgroundColor,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Sign Up',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.backgroundColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(AuthProvider authProvider) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style:
              AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
          children: [
            TextSpan(
              text: 'Log In',
              style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (!authProvider.isLoading) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hintText, Widget? suffixIcon, String? errorText}) {
    return AppTheme.inputDecoration.copyWith(
      hintText: hintText,
      suffixIcon: suffixIcon,
      errorText: errorText,
      hintStyle:
          AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
      errorStyle: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
    );
  }
}
