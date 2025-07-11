import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/core/auth/auth_repository.dart';
import 'package:air_charters/shared/utils/session_manager.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'dart:developer' as dev;

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _status = 'Ready';
  bool _isLoading = false;
  String _backendToken = '';
  String _sessionStatus = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _status = 'Loading initial data...';
    });

    try {
      // Check current auth state
      final authProvider = context.read<AuthProvider>();
      final sessionManager = SessionManager();
      final apiClient = ApiClient();

      setState(() {
        _status =
            'Auth Provider: ${authProvider.isAuthenticated ? "Authenticated" : "Not authenticated"}';
        _sessionStatus =
            'Session Manager: ${sessionManager.isSessionActive ? "Active" : "Inactive"}';
      });

      // Get current token if available
      final authData = await apiClient.getAuth();
      if (authData != null) {
        setState(() {
          _backendToken = authData.accessToken;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error loading initial data: $e';
      });
    }
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing backend connection...';
    });

    try {
      final authRepository = AuthRepository();
      final isConnected = await authRepository.testBackendConnection();

      setState(() {
        _status = isConnected
            ? 'Backend connection successful'
            : 'Backend connection failed';
      });
    } catch (e) {
      setState(() {
        _status = 'Backend connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      setState(() {
        _status = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Signing up...';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signUpWithEmail(email, password, firstName, lastName);

      setState(() {
        _status = 'Sign up successful!';
        _backendToken = authProvider.authData?.accessToken ?? '';
      });

      // Update session status
      final sessionManager = SessionManager();
      setState(() {
        _sessionStatus =
            'Session Manager: ${sessionManager.isSessionActive ? "Active" : "Inactive"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _status = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Signing in...';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithEmail(email, password);

      setState(() {
        _status = 'Sign in successful!';
        _backendToken = authProvider.authData?.accessToken ?? '';
      });

      // Update session status
      final sessionManager = SessionManager();
      setState(() {
        _sessionStatus =
            'Session Manager: ${sessionManager.isSessionActive ? "Active" : "Inactive"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _status = 'Signing out...';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      setState(() {
        _status = 'Sign out successful!';
        _backendToken = '';
        _sessionStatus = 'Session Manager: Not authenticated';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign out failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    setState(() {
      _isLoading = true;
      _status = 'Clearing all data...';
    });

    try {
      final authRepository = AuthRepository();
      await authRepository.clearAllStoredData();

      setState(() {
        _status = 'All data cleared successfully!';
        _backendToken = '';
        _sessionStatus = 'Session Manager: Not authenticated';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to clear data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test Screen'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $_status',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _sessionStatus,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Fields
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              ElevatedButton(
                onPressed: _isLoading ? null : _testBackendConnection,
                child: const Text('Test Backend Connection'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _clearAllData,
                child: const Text('Clear All Data'),
              ),
              const SizedBox(height: 16),

              // Backend Token Display
              if (_backendToken.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Backend Token:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _backendToken,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Loading Indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
