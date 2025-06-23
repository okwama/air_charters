import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/success_toast.dart';
import 'dart:developer' as dev;

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
  String _selectedCountryCode = '+254'; // Default to Kenya
  String _selectedCountryFlag = '🇰🇪';
  bool _isEmailMode = false; // Toggle between phone and email modes

  @override
  void initState() {
    super.initState();
    // Listen to auth provider changes for success messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.successMessage != null) {
        showSuccessToast(context, authProvider.successMessage!);
        // Clear the success message after showing it
        authProvider.clear();
      }
    });
  }

  @override
  void dispose() {
    _phoneEmailController.dispose();
    _passwordController.dispose();
    _phoneEmailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
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

  void _handleSendVerificationCode() async {
    final phoneEmail = _phoneEmailController.text.trim();
    if (phoneEmail.isEmpty) {
      _showErrorSnackBar(_isEmailMode
          ? 'Please enter your email address'
          : 'Please enter your phone number');
      return;
    }

    if (_isEmailMode) {
      // For email mode, we'll use the existing email/password authentication
      // Show a message to use the password field instead
      _showErrorSnackBar(
          'For email authentication, please use the "Sign In with Password" button below');
      return;
    } else {
      // Handle phone number validation and verification
      if (!_isValidPhoneNumberFormat(phoneEmail)) {
        _showErrorSnackBar('Please enter a valid phone number');
        return;
      }

      // Combine country code with phone number
      final fullPhoneNumber = _selectedCountryCode + phoneEmail;
      try {
        await context
            .read<AuthProvider>()
            .sendPhoneVerification(fullPhoneNumber);
        if (mounted) {
          Navigator.of(context)
              .pushNamed('/verify', arguments: fullPhoneNumber);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(e.toString());
        }
      }
    }
  }

  bool _isPhoneNumber(String input) {
    // Check if input contains mostly digits and common phone number characters
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    return phoneRegex.hasMatch(input) &&
        input.replaceAll(RegExp(r'[^\d]'), '').length >= 7;
  }

  bool _isValidPhoneNumberFormat(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // For phone numbers without country code, check if it's a reasonable length
    // Most phone numbers are 7-15 digits when including country code
    // Since we're adding country code separately, check for 7-12 digits
    return digitsOnly.length >= 7 && digitsOnly.length <= 12;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _handleSignInWithPassword() async {
    final email = _phoneEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please enter both email and password');
      return;
    }

    dev.log(
      'Attempting to sign in with email: $email',
      name: 'LoginScreen',
    );

    try {
      await context.read<AuthProvider>().signInWithEmail(email, password);

      // Check if authentication was successful
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        if (mounted) {
          // Show success message
          if (authProvider.successMessage != null) {
            showSuccessToast(context, authProvider.successMessage!);
          }

          // Navigate to home screen
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _selectCountry() async {
    final result = await Navigator.of(context).pushNamed('/country-selection');
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
      _phoneEmailController.clear(); // Clear input when switching modes
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section - Compact
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.interTight(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to your account to continue',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFF666666),
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Form Section
                        Column(
                          children: [
                            // Input Mode Toggle - Compact
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Phone Mode Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_isEmailMode) {
                                          _toggleInputMode();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: !_isEmailMode
                                              ? Colors.black
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.phone_rounded,
                                              size: 16,
                                              color: !_isEmailMode
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Phone',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: !_isEmailMode
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Email Mode Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!_isEmailMode) {
                                          _toggleInputMode();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _isEmailMode
                                              ? Colors.black
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.email_rounded,
                                              size: 16,
                                              color: _isEmailMode
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Email',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: _isEmailMode
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
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

                            // Phone/Email Input Field
                            if (!_isEmailMode) ...[
                              // Phone Input with Country Code Selector - Compact
                              Row(
                                children: [
                                  // Country Code Selector
                                  GestureDetector(
                                    onTap: _selectCountry,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedCountryFlag,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _selectedCountryCode,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Phone Number Input Field
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneEmailController,
                                      focusNode: _phoneEmailFocus,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.phone,
                                      cursorColor: Colors.black,
                                      enabled: !authProvider.isLoading,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Phone number',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: const Color(0xFF888888),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E5E5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF5F5F5),
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Email Input Field - Compact
                              TextFormField(
                                controller: _phoneEmailController,
                                focusNode: _phoneEmailFocus,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Colors.black,
                                enabled: !authProvider.isLoading,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF888888),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E5E5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Password Field - Compact
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              textInputAction: TextInputAction.done,
                              obscureText: !_passwordVisibility,
                              cursorColor: Colors.black,
                              enabled: !authProvider.isLoading,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: _isEmailMode
                                    ? 'Password (required)'
                                    : 'Password (optional)',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF888888),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E5E5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.all(12),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _passwordVisibility =
                                          !_passwordVisibility;
                                    });
                                  },
                                  child: Icon(
                                    _passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Action Buttons - Compact
                            Column(
                              children: [
                                // Send Verification Code Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed:
                                        (authProvider.isLoading || _isEmailMode)
                                            ? null
                                            : _handleSendVerificationCode,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isEmailMode
                                          ? Colors.grey.shade400
                                          : Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _isEmailMode
                                          ? 'Use Password Sign In Below'
                                          : 'Send Verification Code',
                                      style: GoogleFonts.interTight(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Sign In with Password Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: _isEmailMode
                                      ? ElevatedButton(
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : _handleSignInWithPassword,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Sign In',
                                            style: GoogleFonts.interTight(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : OutlinedButton(
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : _handleSignInWithPassword,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            side: const BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            'Sign In with Password',
                                            style: GoogleFonts.interTight(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Error message - Compact
                            if (authProvider.errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.red.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            const SizedBox(height: 16),

                            // OR Divider - Compact
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFE5E5E5),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF888888),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFE5E5E5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Social Login Buttons - Compact
                            Column(
                              children: [
                                // Google Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () {
                                            // Handle Google login
                                          },
                                    icon: const Icon(
                                      Icons.login,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Continue with Google',
                                      style: GoogleFonts.interTight(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: const Color(0xFFF5F5F5),
                                      side: const BorderSide(
                                        color: Color(0xFFE5E5E5),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Apple Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () {
                                            // Handle Apple login
                                          },
                                    icon: const Icon(
                                      Icons.apple,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Continue with Apple',
                                      style: GoogleFonts.interTight(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: const Color(0xFFF5F5F5),
                                      side: const BorderSide(
                                        color: Color(0xFFE5E5E5),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Bottom Section - Compact
                        Column(
                          children: [
                            TextButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () {
                                      // Handle forgot password
                                    },
                              child: Text(
                                'Forgot your password?',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: authProvider.isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context)
                                              .pushNamed('/signup');
                                        },
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
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
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
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
}
