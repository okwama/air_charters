# ✈️ Air Charters App - Comprehensive Project Documentation

This document serves as a comprehensive guide for the development of the Air Charters Flutter application. It consolidates the project's architecture, design principles, feature specifications, and current implementation status to provide a unified reference for development.

**Technologies Used:**

  * **Frontend:** Flutter
  * **Authentication & Notifications:** Firebase (Authentication, Cloud Messaging)
  * **Backend & Database:** MySQL (for core data persistence)
  * **API Communication:** `http` package in Flutter

-----

## 1\. Project Overview

The Air Charters App aims to provide a seamless platform for users to book and manage private air charters and leasing options. It caters to both individual customers for flight bookings and administrators for managing aircraft, rates, and bookings.

## 2\. Project Folder Structure (`/lib`)

The application adheres to a clean, modular, feature-based folder structure to ensure scalability and maintainability.

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
│   │   ├── verify_code_screen.dart
│   │   └── country_selection_screen.dart
│   ├── home/       # Home screen feature
│   │   └── home_screen.dart
│   ├── profile/    # Profile feature
│   ├── settings/   # Settings feature
│   │   └── settings_screen.dart
│   ├── splash/     # Splash screen
│   │   └── splash_screen.dart
│   └── deals/      # Deals feature (added based on provided code)
│       ├── models/        # Data models for deals, flights, bookings
│       │   └── deal_model.dart
│       ├── screens/       # UI screens related to deals/booking
│       │   ├── trip_summary_page.dart
│       │   ├── payment_screen.dart
│       │   └── booking_confirmation_screen.dart
│       └── services/      # API services specific to deals/booking (or use core/network/api_service)
│
├── shared/         # Shared components and utilities
│   ├── components/ # Reusable components
│   │   └── bottom_nav.dart
│   ├── widgets/    # Reusable widgets
│   │   ├── search_bar.dart
│   │   ├── custom_input_field.dart
│   │   ├── custom_button.dart
│   │   ├── success_widget.dart
│   │   ├── offline_toast.dart
│   │   └── app_spinner.dart
│   └── utils/      # Shared utilities
│       └── app_utils.dart
│       └── app_spacing.dart
│
├── constants.dart  # App constants
└── main.dart       # App entry point
```

-----

## 3\. Design Guidelines

### 3.1. Color Tokens (`config/theme/app_theme.dart`)

The application uses a strict black and white theme with specific color tokens:

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

### 3.2. Typography

  * **Font Families:** Google Fonts (Inter, InterTight, Outfit, Plus Jakarta Sans)
  * **Font Sizes:** `heading1`, `heading2`, `heading3`, `bodyLarge`, `bodyMedium`, `bodySmall`, `caption` (defined in `config/theme/app_theme.dart`)

### 3.3. Iconography & Images

  * `.svg` icons are stored in `/assets/icons`.
  * `.png` images are stored in `/assets/images`.
  * `lucide_icons` package is used for consistent iconography.

-----

## 4\. Navigation Structure

### 4.1. Bottom Navigation (`shared/components/bottom_nav.dart`)

The bottom navigation defines core app sections:

```dart
enum NavItem { explore, trips, contact, settings }
```

### 4.2. Route Structure (`main.dart`)

All routes are defined centrally for easy management:

```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/signup': (context) => const SignupScreen(),
  '/login': (context) => const LoginScreen(),
  '/verify': (context) => const VerifyCodeScreen(),
  '/country-selection': (context) => const CountrySelectionScreen(),
  '/home': (context) => const CharterHomePage(),
  '/settings': (context) => const SettingsScreen(),
  // New Routes for Booking Flow:
  '/trip-summary': (context) => const TripSummaryPage(), // Added based on provided code
  '/payment': (context) => const PaymentScreen(), // Added based on provided code
  '/booking-confirmation': (context) => const BookingConfirmationScreen(), // Added based on provided code
}
```

-----

## 5\. Components & Reusability Rules

### 5.1. Widget Naming Convention

  * Widgets are prefixed with `Custom` or descriptive names (e.g., `CustomButton`, `CustomInputField`, `SearchBar`).

### 5.2. File Naming Convention

  * Files use `snake_case` (e.g., `custom_input_field.dart`, `bottom_nav.dart`).

### 5.3. Spacing Constants (`shared/utils/app_spacing.dart`)

  * Shared constants are used for consistent spacing:

<!-- end list -->

```dart
class AppSpacing {
  static const double screenPadding = 16.0;
  static const double elementSpacing = 12.0;
}
```

### 5.4. Page-Level UI Layout (`Scaffold` Structure)

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

-----

## 6\. Authentication Flow (Firebase)

  * **Mechanism:** Firebase Authentication for user identity.
  * **Methods:** Phone number or email-based registration/login, Firebase OTP-based verification, optional password-based login.
  * **Flow:** Splash → Signup → Country Selection → Verification → Home. Login screen is available but not the primary entry point.

-----

## 7\. API Services & Data Handling

### 7.1. API Communication

  * The `http` package is used for all API calls.
  * A dedicated `ApiService` (likely in `core/network/`) will encapsulate API logic.

### 7.2. Backend & Database

  * **Firebase:** Handles user authentication and push notifications (FCM).
  * **MySQL:** Serves as the primary persistent storage for:
      * User Profiles (linked via Firebase UID)
      * Booking records and aircraft details
      * Passenger details, transaction history
      * Charter and leasing configurations

### 7.3. Data Models (`features/deals/models/deal_model.dart`)

  * Models are being created to structure data received from APIs and stored locally. `Deal` and `Flight` models are already in use.

-----

## 8\. State Management

  * Currently using basic Flutter `setState` for local component state.
  * `Provider` package is available and planned for future implementation for larger, app-wide state management.
  * `GetStorage` is used for local persistent storage of user data (e.g., token, userId).

-----

## 9\. Current App Flow & Features Implemented

### 9.1. Customer App Flow (High-Level)

1.  **Download App:** Available on iOS and Android.
2.  **Register or Login:** Via phone number (OTP) or email/password (Firebase).
3.  **Check Flight Availability:** Integrated booking calendar showing open slots (MySQL-driven).
4.  **Choose Aircraft Type:** Helicopter, Fixed-Wing, or Jet.
5.  **Select Service Option:**
      * **Standard:** Executive Flight, Sightseeing, Tours, Emergency Services, Cargo.
      * **Special (Jet Only):** Add-ons like WiFi, Food, Hostess.
6.  **Reserve Flight:** Pick date, time, destination, one-way or round-trip.
7.  **Add Passenger Details:** Name, Age, Nationality, ID/Passport.
8.  **Confirm and Pay:** Payments via M-Pesa or Card; tracked in MySQL.
9.  **Receive Receipt:** Email confirmation with QR code or reference number.
10. **Boarding:** Present e-ticket + ID at the boarding point.

### 9.2. Admin Functionalities (via App)

  * Aircraft Management (Images, Seat Plan, Type)
  * Repositioning Costs Setup (km-based)
  * Rates per hour based on aircraft category
  * Standard/Special Booking Config
  * View Bookings, Customer Details, and Payments
  * Notification Dispatch (FCM)

### 9.3. Leasing Options (via App)

  * Choose Wet Lease (ACMI) or Dry Lease
  * Fill digital lease application
  * Upload required documents (company, aircraft, certificates)
  * Sign lease digitally
  * Pay and get confirmation
  * Manage active leases and renewals

### 9.4. Completed Features Status

| Feature                    | Status | Location             |
| :------------------------- | :----- | :------------------- |
| Clean folder structure     | ✅     | `lib/`    |
| Black/White theme          | ✅     | `config/theme/` |
| Bottom navigation          | ✅     | `shared/components/` |
| Splash screen              | ✅     | `features/splash/` |
| Signup flow                | ✅     | `features/auth/` |
| Country selection          | ✅     | `features/auth/` |
| Verification screen        | ✅     | `features/auth/` |
| Home screen                | ✅     | `features/home/` |
| Settings screen            | ✅     | `features/settings/` |
| Custom components          | ✅     | `shared/widgets/` |
| Search bar                 | ✅     | `shared/widgets/` |

### 9.5. In Progress / Planned Features

| Feature                    | Status | Notes                                                        |
| :------------------------- | :----- | :----------------------------------------------------------- |
| API integration            | 🔄     | HTTP package ready                                |
| State management           | 🔄     | Provider available                                |
| Profile feature            | 🔄     | Folder exists                                     |
| Booking flow               | 📋     | **In Progress:** Trip Summary, Payment Screen, Confirmation (based on provided code) |
| Payment integration        | 📋     | M-Pesa, Card payments (tracked in MySQL)           |
| Loyalty system             | 📋     | Not started                                       |
| Error handling & loading states | 📋     | To be implemented                                 |
| Proper data models         | 📋     | To be implemented                                 |

-----

## 10\. Dependencies (`pubspec.yaml`)

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

-----

## 11\. Performance Considerations

  * Use `cached_network_image` for image optimization.
  * Implement lazy loading for lists.
  * Use `const` constructors where possible.
  * Minimize widget rebuilds.
  * Implement proper loading states.

-----

## 12\. DO NOTs (Prohibited Practices)

  * ❌ Inline styles (use `AppTheme`)
  * ❌ Magic numbers (use constants)
  * ❌ Mixed UI + logic
  * ❌ Hardcoded routes