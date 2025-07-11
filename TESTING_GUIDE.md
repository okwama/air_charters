# User Registration Testing Guide

## 🚀 Overview

This guide will help you test the user registration flow across your Flutter app, NestJS backend, and Firebase integration.

## 📋 Prerequisites

1. **Firebase Project Setup**
   - Ensure your Firebase project is configured
   - Verify the service account key file exists: `air-charters-app-firebase-adminsdk-fbsvc-0337c1ad01.json`
   - Enable Email/Password authentication in Firebase Console

2. **Backend Setup**
   - Database is running and migrated
   - NestJS server is running on port 3000
   - Environment variables are configured

3. **Flutter Setup**
   - Firebase configuration is properly set up
   - Dependencies are installed

## 🧪 Testing Methods

### Method 1: Flutter App Testing (Recommended)

1. **Add Test Screen to Your App**
   ```dart
   // In your main.dart or navigation
   import 'test/auth_test_screen.dart';
   
   // Add this route to your app
   '/auth-test': (context) => const AuthTestScreen(),
   ```

2. **Test Steps**
   - Launch the app and navigate to `/auth-test`
   - Fill in the registration form:
     - Email: `test@example.com`
     - Password: `TestPassword123!`
     - First Name: `John`
     - Last Name: `Doe`
   - Tap "Sign Up"
   - Verify the user is created and Firebase token is obtained
   - Test "Get Token" to see the Firebase ID token
   - Test "Update Profile" to modify user data
   - Test "Sign Out" to clear the session

### Method 2: Backend API Testing

1. **Start the Backend Server**
   ```bash
   cd backend
   npm run start:dev
   ```

2. **Run the Test Script**
   ```bash
   npm run test:registration
   ```

3. **Manual API Testing with curl**
   ```bash
   # Test with invalid token
   curl -X POST http://localhost:3000/auth/firebase/login \
     -H "Content-Type: application/json" \
     -d '{
       "firebaseToken": "invalid-token",
       "userData": {
         "firstName": "John",
         "lastName": "Doe",
         "countryCode": "+1"
       }
     }'

   # Test with valid token (get from Flutter app)
   curl -X POST http://localhost:3000/auth/firebase/login \
     -H "Content-Type: application/json" \
     -d '{
       "firebaseToken": "YOUR_FIREBASE_TOKEN_HERE",
       "userData": {
         "firstName": "John",
         "lastName": "Doe",
         "countryCode": "+1"
       }
     }'
   ```

### Method 3: Automated Testing

1. **Run E2E Tests**
   ```bash
   cd backend
   npm run test:e2e
   ```

2. **Run Unit Tests**
   ```bash
   npm run test
   ```

## 🔍 What to Test

### 1. User Registration Flow
- [ ] User can sign up with email/password
- [ ] Firebase user is created
- [ ] Backend user record is created
- [ ] JWT tokens are generated
- [ ] User data is properly stored

### 2. User Authentication Flow
- [ ] User can sign in with existing credentials
- [ ] Firebase token is verified
- [ ] JWT tokens are refreshed
- [ ] User session is maintained

### 3. Profile Management
- [ ] User profile can be retrieved
- [ ] User profile can be updated
- [ ] Changes are persisted in database

### 4. Error Handling
- [ ] Invalid Firebase tokens are rejected
- [ ] Missing required fields are handled
- [ ] Network errors are handled gracefully
- [ ] Database errors are handled

### 5. Security
- [ ] JWT tokens are properly validated
- [ ] Firebase tokens are verified
- [ ] User data is properly isolated
- [ ] Sensitive data is not exposed

## 📊 Expected Results

### Successful Registration Response
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "user": {
    "id": "firebase-uid-here",
    "email": "test@example.com",
    "phoneNumber": null,
    "firstName": "John",
    "lastName": "Doe",
    "countryCode": "+1",
    "loyaltyPoints": 0,
    "walletBalance": 0,
    "isActive": true,
    "emailVerified": true,
    "phoneVerified": false
  }
}
```

### Database Record
```sql
SELECT * FROM users WHERE email = 'test@example.com';
```

Should return a record with:
- `id`: Firebase UID
- `email`: test@example.com
- `first_name`: John
- `last_name`: Doe
- `email_verified`: 1
- `is_active`: 1

## 🐛 Troubleshooting

### Common Issues

1. **Firebase Configuration Error**
   ```
   Error: Firebase initialization failed
   ```
   - Check if service account key file exists
   - Verify Firebase project ID matches
   - Ensure Firebase Admin SDK is properly initialized

2. **Database Connection Error**
   ```
   Error: Could not connect to database
   ```
   - Check database server is running
   - Verify connection string in environment variables
   - Ensure database schema is migrated

3. **JWT Token Error**
   ```
   Error: Invalid JWT token
   ```
   - Check JWT_SECRET environment variable
   - Verify token expiration settings
   - Ensure token format is correct

4. **Flutter Firebase Error**
   ```
   Error: Firebase Auth not initialized
   ```
   - Check google-services.json (Android) or GoogleService-Info.plist (iOS)
   - Verify Firebase configuration in Flutter
   - Ensure Firebase dependencies are installed

### Debug Steps

1. **Check Backend Logs**
   ```bash
   cd backend
   npm run start:dev
   # Watch for error messages in console
   ```

2. **Check Flutter Logs**
   ```bash
   flutter run
   # Watch for error messages in console
   ```

3. **Verify Database**
   ```sql
   -- Check if user was created
   SELECT * FROM users ORDER BY created_at DESC LIMIT 5;
   
   -- Check for any constraint violations
   SHOW ENGINE INNODB STATUS;
   ```

4. **Test Firebase Directly**
   ```bash
   # Use Firebase CLI to test authentication
   firebase auth:export users.json
   ```

## 📝 Test Checklist

- [ ] Flutter app can register new users
- [ ] Firebase user is created successfully
- [ ] Backend user record is created in database
- [ ] JWT tokens are generated and valid
- [ ] User can sign in with registered credentials
- [ ] Profile can be retrieved and updated
- [ ] Error handling works for invalid inputs
- [ ] Security measures are working
- [ ] Database constraints are enforced
- [ ] Firebase token verification works

## 🎯 Next Steps

After successful testing:

1. **Remove Test Code**
   - Remove the test screen from production builds
   - Clean up test scripts if not needed

2. **Add Production Monitoring**
   - Set up logging for authentication events
   - Monitor database performance
   - Add error tracking

3. **Security Review**
   - Review authentication flow security
   - Test with various attack vectors
   - Implement rate limiting if needed

4. **Performance Testing**
   - Test with multiple concurrent users
   - Monitor response times
   - Optimize database queries if needed 