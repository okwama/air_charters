import 'package:air_charters/features/auth/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/success_toast.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'dart:developer' as dev;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Common
  bool _isEmailMode = false;

  // Phone Mode
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+254'; // Default to Kenya
  String _selectedCountryFlag = '🇰🇪';

  // Email Mode
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisibility = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleSendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return;
    }

    final fullPhoneNumber = _selectedCountryCode + phone;
    try {
      await context.read<AuthProvider>().sendPhoneVerification(fullPhoneNumber);
      if (mounted) {
        Navigator.of(context).pushNamed('/verify', arguments: fullPhoneNumber);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _handleSignUpWithEmail() async {
    print('🔥 SIGNUP SCREEN: _handleSignUpWithEmail CALLED 🔥');
    dev.log('=== SIGNUP SCREEN: _handleSignUpWithEmail CALLED ===',
        name: 'SignupScreen-DEBUG');

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    dev.log(
        'Form data: firstName=$firstName, lastName=$lastName, email=$email, password=${password.isNotEmpty ? "***" : "empty"}',
        name: 'SignupScreen-DEBUG');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      dev.log('Form validation failed - empty fields detected',
          name: 'SignupScreen-WARNING');
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

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
      await authProvider.signUpWithEmail(email, password, firstName, lastName);
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
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
    });
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
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: isHealthy ? Colors.green : Colors.red,
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
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
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
        backgroundColor: Colors.white,
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
                          style: GoogleFonts.interTight(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your journey with us today.',
                          style: GoogleFonts.inter(
                              fontSize: 16, color: const Color(0xFF666666)),
                        ),
                        const SizedBox(height: 40),

                        // More spacious Toggle
                        _buildToggle(),
                        const SizedBox(height: 20),

                        // Test Backend Button (temporary)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _testBackendConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Test Backend Connection',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Form
                        if (_isEmailMode)
                          _buildEmailForm(authProvider)
                        else
                          _buildPhoneForm(authProvider),

                        const SizedBox(height: 24),

                        // More spacious Divider
                        _buildDivider(),
                        const SizedBox(height: 20),

                        // More spacious Social Login
                        _buildSocialButtons(authProvider),

                        const SizedBox(height: 32),

                        // Login Link
                        _buildLoginLink(authProvider),
                      ],
                    ),
                  ),

                  // Loading Overlay
                  if (authProvider.isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            'Phone',
            !_isEmailMode,
            Icons.phone_rounded,
            () {
              if (_isEmailMode) _toggleInputMode();
            },
          ),
          _buildToggleButton(
            'Email',
            _isEmailMode,
            Icons.email_rounded,
            () {
              if (!_isEmailMode) _toggleInputMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String text, bool isSelected, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneForm(AuthProvider authProvider) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _selectCountry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                ),
                child: Row(
                  children: [
                    Text(_selectedCountryFlag,
                        style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(_selectedCountryCode,
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 3),
                    Icon(Icons.keyboard_arrow_down,
                        size: 18, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(hintText: 'Phone number'),
                enabled: !authProvider.isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                authProvider.isLoading ? null : _handleSendVerificationCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Continue',
                style: GoogleFonts.interTight(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
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
                decoration: _inputDecoration(hintText: 'First Name'),
                enabled: !authProvider.isLoading,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration(hintText: 'Last Name'),
                enabled: !authProvider.isLoading,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hintText: 'Email address'),
          enabled: !authProvider.isLoading,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisibility,
          decoration: _inputDecoration(
            hintText: 'Password',
            suffixIcon: InkWell(
              onTap: () =>
                  setState(() => _passwordVisibility = !_passwordVisibility),
              child: Icon(
                  _passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black,
                  size: 20),
            ),
          ),
          enabled: !authProvider.isLoading,
        ),
        const SizedBox(height: 20),

        // More spacious Error message
        if (authProvider.errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleSignUpWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Sign Up',
                style: GoogleFonts.interTight(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E5E5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR',
              style: GoogleFonts.inter(
                  color: const Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E5E5))),
      ],
    );
  }

  Widget _buildSocialButtons(AuthProvider authProvider) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading
                  ? null
                  : () {}, //TODO: Implement Google Sign In
              icon: const Icon(Icons.login, color: Colors.black, size: 18),
              label: Text('Google',
                  style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              style: _socialButtonStyle(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading
                  ? null
                  : () {}, //TODO: Implement Apple Sign In
              icon: const Icon(Icons.apple, color: Colors.black, size: 18),
              label: Text('Apple',
                  style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              style: _socialButtonStyle(),
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
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600),
          children: [
            TextSpan(
              text: 'Log In',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: Colors.black),
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
      {required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle:
          GoogleFonts.inter(fontSize: 16, color: const Color(0xFF888888)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.all(16),
      suffixIcon: suffixIcon,
    );
  }

  ButtonStyle _socialButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFFF5F5F5),
      side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
