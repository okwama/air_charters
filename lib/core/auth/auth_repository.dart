import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env/app_config.dart';
import '../network/api_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Configuration
  static const bool _useBackend = true; // Set to true when backend is ready
  static const String _verificationIdKey = 'firebase_verification_id';
  static const String _backendUrl =
      'http://10.0.2.2:5000'; // For Android emulator, this points to localhost

  // Firebase Auth State Stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current Firebase User
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      if (AppConfig.useBackend) {
        final authData = await _apiClient.getAuth();
        return authData != null && !authData.isExpired;
      } else {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          final authData = await _getLocalAuthData();
          return authData != null && !authData.isExpired;
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Phone Number or Email Authentication
  Future<void> sendPhoneVerification(String phoneNumberOrEmail) async {
    try {
      // Check if it's an email address
      if (phoneNumberOrEmail.contains('@')) {
        // Handle email verification
        await _sendEmailVerification(phoneNumberOrEmail);
      } else {
        // Handle phone number verification
        await _sendPhoneNumberVerification(phoneNumberOrEmail);
      }
    } catch (e) {
      throw AuthException('Failed to send verification code: $e');
    }
  }

  // Send Phone Number Verification
  Future<void> _sendPhoneNumberVerification(String phoneNumber) async {
    // Format phone number to E.164 format
    final formattedPhoneNumber = _formatPhoneNumberToE164(phoneNumber);

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw AuthException(_getFirebaseErrorMessage(e));
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Store verification ID securely
        await _storeVerificationId(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout - verification ID is still valid
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Send Email Verification
  Future<void> _sendEmailVerification(String email) async {
    // For email verification, we'll use Firebase's built-in email verification
    // This will send a verification link to the user's email
    try {
      // Check if user already exists
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);

      if (methods.isNotEmpty) {
        // User exists, send email verification link
        // Note: This requires the user to be signed in, so we'll use a different approach
        throw AuthException(
            'Email verification requires the user to be signed in. Please use phone number verification or sign in with password instead.');
      } else {
        // User doesn't exist, we can't send verification email
        throw AuthException(
            'Email verification is not available for new accounts. Please use phone number verification instead.');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Failed to send email verification: $e');
    }
  }

  // Helper method to format phone number to E.164 format
  String _formatPhoneNumberToE164(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If it already starts with +, return as is
    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    // If it starts with 00, replace with +
    if (cleaned.startsWith('00')) {
      return '+${cleaned.substring(2)}';
    }

    // If it's a Kenyan number (254), add +
    if (cleaned.startsWith('254')) {
      return '+$cleaned';
    }

    // If it's a US number (1), add +
    if (cleaned.startsWith('1') && cleaned.length == 11) {
      return '+$cleaned';
    }

    // If it's a 10-digit US number, assume it's US and add +1
    if (cleaned.length == 10) {
      return '+1$cleaned';
    }

    // If it's a 9-digit Kenyan number, add +254
    if (cleaned.length == 9 && !cleaned.startsWith('0')) {
      return '+254$cleaned';
    }

    // If it's a 10-digit Kenyan number starting with 0, replace 0 with +254
    if (cleaned.length == 10 && cleaned.startsWith('0')) {
      return '+254${cleaned.substring(1)}';
    }

    // Default: add + if not present
    if (!cleaned.startsWith('+')) {
      return '+$cleaned';
    }

    return cleaned;
  }

  // Verify Phone Code
  Future<AuthModel> verifyPhoneCode(String smsCode) async {
    try {
      final verificationId = await _getStoredVerificationId();
      if (verificationId == null) {
        throw AuthException(
            'No verification ID found. Please request a new code.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Failed to authenticate with phone number.');
      }

      // Clear verification ID after successful verification
      await _clearVerificationId();

      if (AppConfig.useBackend) {
        // Get or create user in our backend
        final authData = await _authenticateWithBackend(firebaseUser);
        await _apiClient.saveAuth(authData);
        return authData;
      } else {
        // Firebase-only mode - create local auth data
        final authData = await _createLocalAuthData(firebaseUser);
        await _saveLocalAuthData(authData);
        return authData;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException(_getFirebaseErrorMessage(e));
      } else if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Failed to verify code: ${e.toString()}');
      }
    }
  }

  // Email/Password Authentication
  Future<AuthModel> signInWithEmail(String email, String password) async {
    try {
      dev.log('Signing in Firebase user with email: $email',
          name: 'AuthRepository');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Failed to sign in with email and password.');
      }

      dev.log(
          'Firebase UserCredential (signIn): provider=${userCredential.credential?.providerId}',
          name: 'AuthRepository');
      dev.log(
          'Firebase User: uid=${firebaseUser.uid}, email=${firebaseUser.email}, displayName=${firebaseUser.displayName}, providerData=${firebaseUser.providerData.map((p) => p.providerId).toList()}',
          name: 'AuthRepository');

      dev.log(
        'Checking backend configuration... AppConfig.useBackend = ${AppConfig.useBackend}',
        name: 'AuthRepository-DEBUG',
      );

      if (AppConfig.useBackend) {
        // Authenticate with backend
        dev.log(
            'Backend is enabled. Authenticating with backend for new user: $email',
            name: 'AuthRepository');
        final authData = await _authenticateWithBackend(firebaseUser);
        await _apiClient.saveAuth(authData);
        await _saveLocalAuthData(authData);
        return authData;
      } else {
        // Firebase-only mode
        dev.log('Backend is disabled. Falling back to Firebase-only mode.',
            name: 'AuthRepository');
        // Fallback for Firebase-only mode
        await _createFirestoreUser(firebaseUser, email, email);
        final authData = await _createLocalAuthData(firebaseUser,
            firstName: email, lastName: email);
        await _saveLocalAuthData(authData);
        return authData;
      }
    } catch (e, s) {
      dev.log('Error during signInWithEmail: $e', name: 'AuthRepository-ERROR');
      dev.log('Stack trace: $s', name: 'AuthRepository-ERROR');
      if (e is FirebaseAuthException) {
        throw AuthException(_getFirebaseErrorMessage(e));
      } else {
        throw AuthException(
            'An unexpected error occurred during sign-in. Please try again.');
      }
    }
  }

  // Email/Password Signup
  Future<AuthModel> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    try {
      // 1. Create user in Firebase
      dev.log('Creating user in Firebase with email: $email',
          name: 'AuthRepository');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Failed to create user account.');
      }

      // 2. Update Firebase profile display name
      await firebaseUser.updateDisplayName('$firstName $lastName');

      dev.log(
          'Firebase UserCredential (signUp): isNewUser=${userCredential.additionalUserInfo?.isNewUser}',
          name: 'AuthRepository');
      dev.log(
          'Firebase User: uid=${firebaseUser.uid}, email=${firebaseUser.email}, displayName=${firebaseUser.displayName}, providerData=${firebaseUser.providerData.map((p) => p.providerId).toList()}',
          name: 'AuthRepository');

      // =================================================================
      //  NEW DIAGNOSTIC LOG
      // =================================================================
      dev.log(
        'Checking backend configuration... AppConfig.useBackend = ${AppConfig.useBackend}',
        name: 'AuthRepository-DEBUG',
      );

      // 3. Authenticate with our backend to create the user in our DB
      if (AppConfig.useBackend) {
        dev.log(
            'Backend is enabled. Authenticating with backend for new user: $firstName $lastName',
            name: 'AuthRepository');
        final authData = await _authenticateWithBackend(firebaseUser,
            firstName: firstName, lastName: lastName);
        await _apiClient.saveAuth(authData);
        return authData;
      } else {
        dev.log('Backend is disabled. Falling back to Firebase-only mode.',
            name: 'AuthRepository');
        // Fallback for Firebase-only mode
        await _createFirestoreUser(firebaseUser, firstName, lastName);
        final authData = await _createLocalAuthData(firebaseUser,
            firstName: firstName, lastName: lastName);
        await _saveLocalAuthData(authData);
        return authData;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to sign up: ${e.toString()}');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _apiClient.clearAuth();
    await _clearLocalAuthData();
  }

  // Get Current User
  Future<UserModel?> getCurrentUser() async {
    try {
      if (AppConfig.useBackend) {
        final authData = await _apiClient.getAuth();
        return authData?.user;
      } else {
        final authData = await _getLocalAuthData();
        return authData?.user;
      }
    } catch (e) {
      return null;
    }
  }

  // Update User Profile
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? countryCode,
  }) async {
    try {
      if (AppConfig.useBackend) {
        final response = await _apiClient.put('/api/auth/customer/profile', {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (countryCode != null) 'country_code': countryCode,
        });

        final updatedUser = UserModel.fromJson(response['user']);

        // Update stored auth data
        final currentAuth = await _apiClient.getAuth();
        if (currentAuth != null) {
          final updatedAuth = currentAuth.copyWith(user: updatedUser);
          await _apiClient.saveAuth(updatedAuth);
        }

        return updatedUser;
      } else {
        // Firebase-only mode - update Firebase user profile
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          if (firstName != null && lastName != null) {
            await firebaseUser.updateDisplayName('$firstName $lastName');
          }

          // Update local auth data
          final currentAuth = await _getLocalAuthData();
          if (currentAuth != null) {
            final updatedUser = currentAuth.user.copyWith(
              firstName: firstName ?? currentAuth.user.firstName,
              lastName: lastName ?? currentAuth.user.lastName,
              phoneNumber: phoneNumber ?? currentAuth.user.phoneNumber,
              countryCode: countryCode ?? currentAuth.user.countryCode,
            );
            final updatedAuth = currentAuth.copyWith(user: updatedUser);
            await _saveLocalAuthData(updatedAuth);
            return updatedUser;
          }
        }
        throw AuthException('No user found to update.');
      }
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }

  // Refresh Token
  Future<AuthModel?> refreshToken() async {
    try {
      if (AppConfig.useBackend) {
        return await _apiClient.refreshToken();
      } else {
        // Firebase-only mode - refresh Firebase token
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          await firebaseUser.getIdToken(true); // Force refresh
          final authData = await _createLocalAuthData(firebaseUser);
          await _saveLocalAuthData(authData);
          return authData;
        }
        return null;
      }
    } catch (e) {
      throw AuthException('Failed to refresh token: $e');
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        if (AppConfig.useBackend) {
          await _apiClient.delete('/api/auth/customer/profile');
        }
        await firebaseUser.delete();
      }
      await _clearLocalAuthData();
      if (AppConfig.useBackend) {
        await _apiClient.clearAuth();
      }
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  // Helper Methods

  Future<AuthModel> _authenticateWithBackend(User firebaseUser,
      {String? firstName, String? lastName}) async {
    try {
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) {
        throw AuthException('Could not retrieve authentication token.');
      }
      dev.log('Authenticating with backend server...', name: 'AuthRepository');
      dev.log('Firebase ID Token: ${idToken.substring(0, 30)}...',
          name: 'AuthRepository');
      dev.log('User details: firstName: $firstName, lastName: $lastName',
          name: 'AuthRepository');
      return await _apiClient.authenticateWithBackend(idToken,
          firstName: firstName, lastName: lastName);
    } catch (e) {
      // Log the specific error for better debugging
      print('Backend authentication failed: $e');
      throw AuthException('Failed to communicate with the application server.');
    }
  }

  Future<AuthModel> _createUserInBackend(
      User firebaseUser, String firstName, String lastName) async {
    try {
      final idToken = await firebaseUser.getIdToken();

      final response = await _apiClient.post('/api/auth/customer/register', {
        'firebase_uid': firebaseUser.uid,
        'id_token': idToken,
        'email': firebaseUser.email,
        'first_name': firstName,
        'last_name': lastName,
      });

      return AuthModel.fromJson(response);
    } catch (e) {
      throw AuthException('Failed to create user in backend: $e');
    }
  }

  // Firebase-only mode helpers
  Future<AuthModel> _createLocalAuthData(
    User firebaseUser, {
    String? firstName,
    String? lastName,
  }) async {
    final idTokenResult = await firebaseUser.getIdTokenResult();
    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phoneNumber: firebaseUser.phoneNumber,
      firstName: firstName ?? firebaseUser.displayName?.split(' ').first,
      lastName: lastName ??
          (firebaseUser.displayName != null &&
                  firebaseUser.displayName!.split(' ').length > 1
              ? firebaseUser.displayName?.split(' ').last
              : ''),
      profileImageUrl: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      phoneVerified: firebaseUser.phoneNumber != null,
    );
    return AuthModel.fromFirebase(idTokenResult, userModel);
  }

  Future<void> _createFirestoreUser(
      User firebaseUser, String firstName, String lastName) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
    await userRef.set({
      'id': firebaseUser.uid,
      'email': firebaseUser.email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': firebaseUser.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Local storage helpers
  Future<void> _saveLocalAuthData(AuthModel authData) async {
    await _secureStorage.write(
      key: AppConfig.localAuthDataKey,
      value: json.encode(authData.toJson()),
    );
  }

  Future<AuthModel?> _getLocalAuthData() async {
    final data = await _secureStorage.read(key: AppConfig.localAuthDataKey);
    if (data != null) {
      try {
        // Parse the stored JSON string properly
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            json.decode(data) as Map<String, dynamic>);
        return AuthModel.fromJson(jsonData);
      } catch (e) {
        // If parsing fails, try to clear the corrupted data and return null
        await _clearLocalAuthData();
        return null;
      }
    }
    return null;
  }

  Future<void> _clearLocalAuthData() async {
    await _secureStorage.delete(key: AppConfig.localAuthDataKey);
  }

  // Verification ID Storage
  Future<void> _storeVerificationId(String verificationId) async {
    await _secureStorage.write(
      key: AppConfig.firebaseVerificationIdKey,
      value: verificationId,
    );
  }

  Future<String?> _getStoredVerificationId() async {
    return await _secureStorage.read(key: AppConfig.firebaseVerificationIdKey);
  }

  Future<void> _clearVerificationId() async {
    await _secureStorage.delete(key: AppConfig.firebaseVerificationIdKey);
  }

  // Clear user data from Firestore (for troubleshooting)
  Future<void> _clearUserFromFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      // Ignore errors when clearing data
      print('Error clearing user from Firestore: $e');
    }
  }

  // Clear all stored data (for troubleshooting)
  Future<void> clearAllStoredData() async {
    try {
      // Clear local storage
      await _clearLocalAuthData();
      await _clearVerificationId();

      // Clear Firestore data if user is authenticated
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _clearUserFromFirestore(firebaseUser.uid);
      }

      if (AppConfig.useBackend) {
        await _apiClient.clearAuth();
      }
    } catch (e) {
      // Ignore errors when clearing data
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new code.';
      case 'quota-exceeded':
        return 'Too many verification attempts. Please try again later.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  // Fetch user details from Firestore
  Future<Map<String, dynamic>?> _fetchUserDetailsFromFirestore(
      String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data is Map<String, dynamic>) {
          return data;
        }
      }
      return null;
    } catch (e) {
      // Log the error but don't throw - this is optional data
      print('Error fetching user details from Firestore: $e');
      return null;
    }
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserInFirestore(
    User firebaseUser, {
    String? firstName,
    String? lastName,
  }) async {
    try {
      final userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'phoneNumber': firebaseUser.phoneNumber,
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'emailVerified': firebaseUser.emailVerified,
        'phoneVerified': firebaseUser.phoneNumber != null,
        'createdAt': firebaseUser.metadata.creationTime?.toIso8601String(),
        'lastSignInAt': firebaseUser.metadata.lastSignInTime?.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(firebaseUser.uid).set(
            userData,
            SetOptions(merge: true), // Merge with existing data
          );
    } catch (e) {
      // Log the error but don't throw - this is optional
      print('Error creating/updating user in Firestore: $e');
    }
  }
}
