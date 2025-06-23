# ✈️ Air Charters App – Cursor Project Guidelines (Flutter)

## 📁 1. Project Folder Structure (Inside `/lib`)

```
lib/
├── config/         # App configuration
│   ├── env/        # Environment variables
│   └── theme/      # Theme configuration
│       └── app_theme.dart
│
├── core/           # Core functionality, base classes, and utilities
│   ├── error/      # Error handling
│   ├── network/    # Network related code
│   └── storage/    # Local storage
│
├── features/       # Feature-based modules
│   ├── auth/       # Authentication feature
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── verifycode.dart
│   │   └── country_selection_screen.dart
│   ├── home/       # Home screen feature
│   │   └── home_screen.dart
│   ├── profile/    # Profile feature
│   ├── settings/   # Settings feature
│   │   └── settings.dart
│   └── splash/     # Splash screen
│       └── splash_screen.dart
│
├── shared/         # Shared components and utilities
│   ├── components/ # Reusable components
│   │   └── bottom_nav.dart
│   ├── widgets/    # Reusable widgets
│   │   ├── searchbar.dart
│   │   ├── custom_input_field.dart
│   │   ├── custom_button.dart
│   │   ├── success_widget.dart
│   │   ├── offline_toast.dart
│   │   └── app_spinner.dart
│   └── utils/      # Shared utilities
│       └── app_utils.dart
│
├── constants.dart  # App constants
└── main.dart       # App entry point
```

## 🎯 2. Design Rules

### 🎨 Color Tokens (`config/theme/app_theme.dart`)
```dart
class AppTheme {
  // Black and White Theme
  static const Color primaryColor = Color(0xFF000000); // Black
  static const Color secondaryColor = Color(0xFF1A1A1A); // Dark Gray
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color errorColor = Color(0xFFE53E3E); // Red
  static const Color successColor = Color(0xFF38A169); // Green
  static const Color textPrimaryColor = Color(0xFF000000); // Black
  static const Color textSecondaryColor = Color(0xFF666666); // Gray
  static const Color borderColor = Color(0xFFE5E5E5); // Light Gray
}
```

### 🧱 Typography
- Font families: `Google Fonts` (Inter, InterTight, Outfit, Plus Jakarta Sans)
- Font sizes: `heading1`, `heading2`, `heading3`, `bodyLarge`, `bodyMedium`, `bodySmall`, `caption`
- Defined in `config/theme/app_theme.dart`

## 🧭 3. Navigation Structure

### Bottom Navigation (`shared/components/bottom_nav.dart`)
```dart
enum NavItem { explore, trips, contact, settings }
```

### Route Structure (`main.dart`)
```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/signup': (context) => const SignupScreen(),
  '/login': (context) => const LoginScreen(),
  '/verify': (context) => const VerifyCodeScreen(),
  '/country-selection': (context) => const CountrySelectionScreen(),
  '/home': (context) => const CharterHomePage(),
  '/settings': (context) => const SettingsScreen(),
}
```

## 🧩 4. Components & Reusability Rules

### Widget Naming
- Prefix: `CustomButton`, `CustomInputField`, `SearchBar`, etc.

### File Naming
- Use `snake_case` e.g. `custom_input_field.dart`, `bottom_nav.dart`

### Widget Rules
- Use shared constants for spacing:
```dart
class AppSpacing {
  static const double screenPadding = 16.0;
  static const double elementSpacing = 12.0;
}
```

## 🔐 5. Auth Flow
- Native Flutter navigation (no Supabase currently)
- Flow: Splash → Signup → Country Selection → Verification → Home
- Login screen available but not in main flow

## 🔄 6. API Services
- Use `http` package for API calls
- No Express backend currently implemented
- Placeholder for future API integration

## 🌍 7. State Management
- Currently using basic Flutter state management
- `Provider` package available but not implemented
- `Get` package available for future use

## 🧠 8. Visual Components
- Use `.svg` icons in `/assets/icons`
- Use `.png` images in `/assets/images`
- Use `lucide_icons` package for consistent iconography

## 📲 9. Page-Level UI Layout
```dart
Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text("Title"),
  ),
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: ...
  ),
  bottomNavigationBar: BottomNav(currentIndex: 0),
)
```

## 📦 10. Current App Flow
1. Splash screen (3 seconds) → "Get Started" button
2. Signup screen → Country selection
3. Country selection → Back to signup with selected code
4. Phone number entry → Verification
5. Code verification → Home screen
6. Home screen with deals and experiences tabs
7. Settings screen accessible via bottom nav

## 🛂 11. Features Implemented
- ✅ Splash screen with timer
- ✅ Signup with country code selection
- ✅ Phone verification flow
- ✅ Home screen with deals
- ✅ Settings screen with user info
- ✅ Bottom navigation
- ✅ Search bar component
- ✅ Custom input fields and buttons
- ✅ Black and white theme

## 🧪 12. Dependencies (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.2.0
  google_fonts: ^6.1.0
  get: ^4.6.6
  get_storage: ^2.1.1
  provider: ^6.1.1
  lucide_icons: ^0.257.0
  stop_watch_timer: ^3.0.0
  cached_network_image: ^3.3.1
  http: ^1.1.2
  shared_preferences: ^2.2.2
```

## 🚫 13. DO NOTs
- ❌ Inline styles (use AppTheme)
- ❌ Magic numbers (use constants)
- ❌ Mixed UI + logic
- ❌ Hardcoded routes

## 📖 14. Current Implementation Status

### ✅ Completed Features
| Feature                    | Status | Location |
|----------------------------|--------|----------|
| Clean folder structure     | ✅     | lib/     |
| Black/White theme          | ✅     | config/theme/ |
| Bottom navigation          | ✅     | shared/components/ |
| Splash screen              | ✅     | features/splash/ |
| Signup flow                | ✅     | features/auth/ |
| Country selection          | ✅     | features/auth/ |
| Verification screen        | ✅     | features/auth/ |
| Home screen                | ✅     | features/home/ |
| Settings screen            | ✅     | features/settings/ |
| Custom components          | ✅     | shared/widgets/ |
| Search bar                 | ✅     | shared/widgets/ |

### 🔄 In Progress / Planned
| Feature                    | Status | Notes |
|----------------------------|--------|-------|
| API integration            | 🔄     | HTTP package ready |
| State management           | 🔄     | Provider available |
| Profile feature            | 🔄     | Folder exists |
| Booking flow               | 📋     | Not started |
| Payment integration        | 📋     | Not started |
| Loyalty system             | 📋     | Not started |

## 🎯 15. Next Steps
1. Implement API services with HTTP package
2. Add state management with Provider
3. Complete profile feature
4. Implement booking flow
5. Add payment integration
6. Build loyalty system
7. Add error handling and loading states
8. Implement proper data models

## 📊 16. Performance Considerations
- Use `cached_network_image` for image optimization
- Implement lazy loading for lists
- Use `const` constructors where possible
- Minimize widget rebuilds
- Implement proper loading states