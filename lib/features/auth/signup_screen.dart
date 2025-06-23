import 'package:air_charters/features/auth/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/shared/widgets/success_toast.dart';
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
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    dev.log(
      'Attempting to sign up with email: $email, name: $firstName $lastName',
      name: 'SignupScreen',
    );

    try {
      await context
          .read<AuthProvider>()
          .signUpWithEmail(email, password, firstName, lastName);

      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        if (mounted) {
          if (authProvider.successMessage != null) {
            showSuccessToast(context, authProvider.successMessage!);
          }
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Compact Header
                        Text(
                          'Create Account',
                          style: GoogleFonts.interTight(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start your journey with us today.',
                          style: GoogleFonts.inter(
                              fontSize: 15, color: const Color(0xFF666666)),
                        ),
                        const SizedBox(height: 20),

                        // Compact Toggle
                        _buildToggle(),
                        const SizedBox(height: 16),

                        // Form
                        if (_isEmailMode)
                          _buildEmailForm(authProvider)
                        else
                          _buildPhoneForm(authProvider),

                        const SizedBox(height: 16),

                        // Compact Divider
                        _buildDivider(),
                        const SizedBox(height: 16),

                        // Compact Social Login
                        _buildSocialButtons(authProvider),

                        const SizedBox(height: 24),

                        // Login Link
                        _buildLoginLink(authProvider),
                      ],
                    ),
                  ),

                  // Loading Overlay
                  if (authProvider.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
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
        borderRadius: BorderRadius.circular(10),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
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
                  fontSize: 13,
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed:
                authProvider.isLoading ? null : _handleSendVerificationCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Continue',
                style: GoogleFonts.interTight(
                    fontSize: 15, fontWeight: FontWeight.w600)),
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hintText: 'Email address'),
          enabled: !authProvider.isLoading,
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 16),

        // Compact Error message
        if (authProvider.errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              authProvider.errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
        ],

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleSignUpWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Sign Up',
                style: GoogleFonts.interTight(
                    fontSize: 15, fontWeight: FontWeight.w600)),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR',
              style: GoogleFonts.inter(
                  color: const Color(0xFF888888), 
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
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
            height: 48,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading
                  ? null
                  : () {}, //TODO: Implement Google Sign In
              icon: const Icon(Icons.login, color: Colors.black, size: 18),
              label: Text('Google',
                  style: GoogleFonts.interTight(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              style: _socialButtonStyle(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading
                  ? null
                  : () {}, //TODO: Implement Apple Sign In
              icon: const Icon(Icons.apple, color: Colors.black, size: 18),
              label: Text('Apple',
                  style: GoogleFonts.interTight(
                      fontSize: 14,
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
          style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade600),
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
          GoogleFonts.inter(fontSize: 15, color: const Color(0xFF888888)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.all(14),
      suffixIcon: suffixIcon,
    );
  }

  ButtonStyle _socialButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFFF5F5F5),
      side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}