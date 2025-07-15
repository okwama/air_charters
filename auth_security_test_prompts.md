# Authentication Security Test Prompts

## 🧪 Testing Your Authentication Security

Since you mentioned that bottom navigation is only accessible when logged in, let's test the actual security vulnerabilities with these specific prompts:

## 1. **Direct Route Access Test**
**Prompt**: Test if you can access protected routes directly without authentication

### Test Steps:
1. **Make sure you're logged OUT**
2. **Add these test buttons to your landing screen temporarily**:
```dart
// Add to landing_screen.dart for testing
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/home'),
  child: Text('Direct to Home'),
),
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/profile'),
  child: Text('Direct to Profile'),
),
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/settings'),
  child: Text('Direct to Settings'),
),
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/trips'),
  child: Text('Direct to Trips'),
),
```

### Expected Behavior:
- ✅ **SECURE**: Should redirect to landing/login screen
- ❌ **VULNERABLE**: Shows the protected screen content

## 2. **Deep Link Security Test**
**Prompt**: Test if deep links can bypass authentication

### Test Steps:
1. **While logged OUT**, try these deep links:
   - `your-app://home`
   - `your-app://profile`
   - `your-app://settings`
   - `your-app://trips`

### Expected Behavior:
- ✅ **SECURE**: Should redirect to landing/login screen
- ❌ **VULNERABLE**: Shows the protected screen content

## 3. **Session Expiration Test**
**Prompt**: Test behavior when session expires while using the app

### Test Steps:
1. **Log in** to your app
2. **Navigate to profile/settings** 
3. **Manually clear token** (simulate expiration):
```dart
// Add this test button to settings screen
ElevatedButton(
  onPressed: () async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.clearAllDataAndRestart();
  },
  child: Text('TEST: Clear Session'),
),
```
4. **Try navigating** using bottom nav after clearing session

### Expected Behavior:
- ✅ **SECURE**: Should redirect to landing/login screen
- ❌ **VULNERABLE**: Still shows protected content

## 4. **Token Validation Test**
**Prompt**: Test if expired tokens are properly handled

### Test Steps:
1. **Log in** to your app
2. **Wait for token to expire** (or manually set expired token)
3. **Try accessing** profile, settings, or any protected feature
4. **Check network requests** - do they fail with 401?

### Expected Behavior:
- ✅ **SECURE**: Should auto-logout and redirect to login
- ❌ **VULNERABLE**: Continues to work with expired token

## 5. **Route Registration Security Test**
**Prompt**: Check if your routes are actually protected

### Current Route Analysis:
Looking at your `main.dart` routes:
```dart
routes: {
  '/home': (context) => const CharterHomePage(),      // ⚠️ No auth guard
  '/settings': (context) => const SettingsScreen(),   // ⚠️ No auth guard  
  '/profile': (context) => const ProfileScreen(),     // ⚠️ No auth guard
  '/trips': (context) => const TripsPage(),           // ⚠️ No auth guard
  '/booking-detail': (context) => const BookingDetailPage(...), // ⚠️ No auth guard
}
```

### Test Steps:
1. **Add debug navigation** to test direct route access
2. **Check if AuthWrapper catches** direct navigation
3. **Verify route-level protection** vs app-level protection

## 6. **Browser/Web Security Test** (if applicable)
**Prompt**: Test web-specific vulnerabilities

### Test Steps:
1. **Open browser dev tools**
2. **Navigate to** `localhost:port/#/home` while logged out
3. **Try manual URL changes** to protected routes
4. **Check localStorage/sessionStorage** for tokens

## 7. **Background/Foreground Security Test**
**Prompt**: Test session handling when app goes background

### Test Steps:
1. **Log in** to app
2. **Put app in background** for extended time
3. **Bring app to foreground**
4. **Try accessing** protected features

### Expected Behavior:
- ✅ **SECURE**: Should validate session and redirect if expired
- ❌ **VULNERABLE**: Works without session validation

## 8. **Navigation Stack Security Test**
**Prompt**: Test if navigation stack can be manipulated

### Test Steps:
1. **Log in** to app
2. **Navigate to** protected screen
3. **Log out** (but don't navigate away)
4. **Try using** device back button or navigation

### Expected Behavior:
- ✅ **SECURE**: Should clear navigation stack and redirect
- ❌ **VULNERABLE**: Can navigate back to protected content

## 🔍 **Quick Security Check Commands**

### Test 1: Direct Route Access
```bash
# Run this in your terminal while app is running
flutter test --dart-define=TEST_DIRECT_ROUTES=true
```

### Test 2: Authentication Flow
```bash
# Check authentication state
flutter logs | grep -i "auth\|token"
```

### Test 3: Route Protection
```bash
# Test route navigation
flutter test test/auth_test.dart
```

## 📊 **Results Interpretation**

### ✅ **Your App is SECURE if:**
- Direct route navigation redirects to login
- Deep links are properly handled
- Session expiration triggers logout
- Token validation works correctly
- Navigation stack is cleared on logout

### ❌ **Your App is VULNERABLE if:**
- Any protected route shows content without authentication
- Deep links bypass authentication
- Expired sessions continue to work
- Navigation stack retains protected screens after logout

## 🛠️ **Quick Fix Template** (if needed)

If you find vulnerabilities, here's the fix pattern:

```dart
// lib/core/guards/auth_guard.dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  
  const AuthGuard({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated || !authProvider.hasValidToken) {
          // Redirect to landing screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/landing', 
              (route) => false
            );
          });
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
```

## 📝 **Test Results Template**

**Test 1 - Direct Routes**: ✅ SECURE / ❌ VULNERABLE  
**Test 2 - Deep Links**: ✅ SECURE / ❌ VULNERABLE  
**Test 3 - Session Expiration**: ✅ SECURE / ❌ VULNERABLE  
**Test 4 - Token Validation**: ✅ SECURE / ❌ VULNERABLE  
**Test 5 - Route Registration**: ✅ SECURE / ❌ VULNERABLE  

**Overall Security Status**: ✅ SECURE / ⚠️ NEEDS ATTENTION / ❌ VULNERABLE

---

**Next Steps**: Run these tests and report back with your findings. Based on the results, I can provide specific fixes for any vulnerabilities you discover.