import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/success_toast.dart';

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

  void _handleSendVerificationCode() async {
    final phoneEmail = _phoneEmailController.text.trim();
    if (phoneEmail.isEmpty) {
      // Clear any previous errors and don't set new ones for empty fields
      // The inline error container will handle this through AuthProvider
      return;
    }

    if (_isEmailMode) {
      // For email mode, we'll use the existing email/password authentication
      // Don't show error - just return silently since this button is disabled in email mode
      return;
    } else {
      // Handle phone number validation and verification
      if (!_isValidPhoneNumberFormat(phoneEmail)) {
        // Let the AuthProvider handle the error state
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
        // Error will be handled by AuthProvider and shown in inline container
        // No need to show snackbar
      }
    }
  }

  // Removed unused method: _isPhoneNumber

  bool _isValidPhoneNumberFormat(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // For phone numbers without country code, check if it's a reasonable length
    // Most phone numbers are 7-15 digits when including country code
    // Since we're adding country code separately, check for 7-12 digits
    return digitsOnly.length >= 7 && digitsOnly.length <= 12;
  }

  // Removed unused method: _isValidEmail

  void _handleSignInWithPassword() async {
    final email = _phoneEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Don't show error for empty fields - let form validation handle it
      return;
    }

    print('🔥 LOGIN SCREEN: Attempting to sign in with email: $email');

    try {
      print('🔥 LOGIN SCREEN: Calling authProvider.signInWithEmail');
      await context.read<AuthProvider>().signInWithEmail(email, password);

      // Check if authentication was successful
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        print(
            '🔥 LOGIN SCREEN: Authentication completed, isAuthenticated: ${authProvider.isAuthenticated}');
        if (authProvider.isAuthenticated) {
          // Login successful
          print('🔥 LOGIN SCREEN: Login successful');

          // Show success message
          if (authProvider.successMessage != null) {
            showSuccessToast(context, authProvider.successMessage!);
          }

          // Navigate to main navigation screen (which includes bottom nav)
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          print(
              '🔥 LOGIN SCREEN: Authentication failed - user not authenticated');
          // Error message will be shown in the inline container via AuthProvider
        }
      }
    } catch (e) {
      print('🔥 LOGIN SCREEN: Authentication error: $e');
      // Error will be handled by AuthProvider and shown in inline container
      // No need for additional error handling here
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section - More spacious
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.interTight(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to your account to continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFF666666),
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Form Section
                        Column(
                          children: [
                            // Input Mode Toggle - More spacious
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
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
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: !_isEmailMode
                                              ? Colors.black
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                fontSize: 14,
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
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          color: _isEmailMode
                                              ? Colors.black
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                fontSize: 14,
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
                              // Phone Input with Country Code Selector - More spacious
                              Row(
                                children: [
                                  // Country Code Selector
                                  GestureDetector(
                                    onTap: _selectCountry,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(12),
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
                                  const SizedBox(width: 12),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Phone number',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: const Color(0xFF888888),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E5E5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF5F5F5),
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Email Input Field - More spacious
                              TextFormField(
                                controller: _phoneEmailController,
                                focusNode: _phoneEmailFocus,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Colors.black,
                                enabled: !authProvider.isLoading,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF888888),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E5E5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // Password Field - More spacious
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              textInputAction: TextInputAction.done,
                              obscureText: !_passwordVisibility,
                              cursorColor: Colors.black,
                              enabled: !authProvider.isLoading,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: _isEmailMode
                                    ? 'Password (required)'
                                    : 'Password (optional)',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF888888),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E5E5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.all(16),
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
                            const SizedBox(height: 24),

                            // Action Buttons - More spacious
                            Column(
                              children: [
                                // Send Verification Code Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _isEmailMode
                                          ? 'Use Password Sign In Below'
                                          : 'Send Verification Code',
                                      style: GoogleFonts.interTight(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Sign In with Password Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
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
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Sign In',
                                            style: GoogleFonts.interTight(
                                              fontSize: 16,
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
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Sign In with Password',
                                            style: GoogleFonts.interTight(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Error message - More spacious
                            if (authProvider.errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.red.shade200),
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

                            const SizedBox(height: 24),

                            // OR Divider - More spacious
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
                                      horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
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
                            const SizedBox(height: 20),

                            // Social Login Buttons - More spacious
                            Column(
                              children: [
                                // Google Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
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
                                        fontSize: 16,
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Apple Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
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
                                        fontSize: 16,
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Bottom Section - More spacious
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(width: 6),
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
                                      fontSize: 15,
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
