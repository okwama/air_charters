# Air Charters Flutter App Documentation

## 📱 Overview

Air Charters is a Flutter-based mobile application for booking private jet charters and luxury air travel services globally. The app provides a seamless booking experience with real-time availability, secure payments, and comprehensive trip management.

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # Application entry point
├── constants.dart               # App-wide constants
├── config/                      # Configuration files
│   ├── env/app_config.dart      # Environment configuration
│   └── theme/app_theme.dart     # UI theming
├── core/                        # Business logic layer
│   ├── models/                  # Data models
│   ├── services/                # API services
│   ├── providers/               # State management
│   ├── controllers/             # Business controllers
│   ├── network/                 # Network layer
│   ├── auth/                    # Authentication
│   └── error/                   # Error handling
├── features/                    # Feature-based modules
│   ├── auth/                    # Authentication screens
│   ├── booking/                 # Booking workflow
│   ├── home/                    # Main dashboard
│   ├── profile/                 # User profile
│   ├── settings/                # App settings
│   ├── mytrips/                 # Trip management
│   ├── direct_charter/          # Direct charter booking
│   ├── experiences/             # Experience packages
│   ├── plan/                    # Trip planning
│   └── splash/                  # Loading screens
└── shared/                      # Reusable components
    ├── components/              # UI components
    ├── widgets/                 # Custom widgets
    └── utils/                   # Utilities
```

### Technology Stack

#### State Management
- **Provider** (`provider: ^6.1.1`) - Main state management solution
- **Get** (`get: ^4.6.6`) - Navigation and dependency injection
- **Get Storage** (`get_storage: ^2.1.1`) - Local storage

#### UI & Styling
- **Google Fonts** (`google_fonts: ^6.1.0`) - Typography
- **Flutter SVG** (`flutter_svg: ^2.2.0`) - SVG rendering
- **Lucide Icons** (`lucide_icons: ^0.257.0`) - Icon library
- **Shimmer** (`shimmer: ^3.0.0`) - Loading animations
- **Cached Network Image** (`cached_network_image: ^3.3.1`) - Image caching

#### Authentication & Backend
- **HTTP** (`http: ^1.1.2`) - API requests
- **JWT Decoder** (`jwt_decoder: ^2.0.1`) - Token management
- **Flutter Secure Storage** (`flutter_secure_storage: ^9.0.0`) - Secure token storage
- **Connectivity Plus** (`connectivity_plus: ^5.0.2`) - Network connectivity

#### Payments
- **Flutter Stripe** (`flutter_stripe: ^11.5.0`) - Payment processing

#### Utilities
- **Shared Preferences** (`shared_preferences: ^2.2.2`) - Local storage
- **Country Picker** (`country_picker: ^2.0.26`) - Country selection
- **Country Flags** (`country_flags: ^3.0.0`) - Flag display
- **Stop Watch Timer** (`stop_watch_timer: ^3.0.0`) - Timer functionality

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.6.1)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd air_charters
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Update `lib/config/env/app_config.dart` with your backend URL
   - Configure Stripe publishable key in `main.dart`

4. **Run the application**
   ```bash
   flutter run
   ```

### Environment Configuration

#### Backend Configuration
```dart
// lib/config/env/app_config.dart
class AppConfig {
  static const String backendUrl = 'http://192.168.100.2:5000';
  static const bool useBackend = true;
  static const int apiTimeoutSeconds = 30;
  static const int tokenRefreshThresholdMinutes = 5;
}
```

#### Stripe Configuration
```dart
// main.dart
Stripe.publishableKey = 'pk_test_51RTguYIo90LS4Ah4PiXhCbadG1lxbzAZAvYqwtjW9qNcjGqcIvc7a5IDVhIF9H5YrOWGZ8Yvo8LrxtfU5BNvSuhm00KykUKxUF';
```

## 📱 Features

### Authentication
- **Login/Signup**: Email and password authentication
- **Phone Verification**: SMS-based verification
- **Country Selection**: International phone number support
- **JWT Token Management**: Secure token storage and refresh

### Booking System
- **Charter Deals**: Browse available charter packages
- **Direct Charter**: Custom charter booking
- **Booking Confirmation**: Detailed booking information
- **Payment Integration**: Stripe payment processing

### Trip Management
- **My Trips**: View booking history
- **Trip Details**: Detailed trip information
- **Status Tracking**: Real-time booking status

### User Profile
- **Profile Management**: User information and preferences
- **Settings**: App configuration
- **Payment Methods**: Saved payment cards

## 🔧 Development Guidelines

### Code Organization

#### Feature-Based Architecture
Each feature is organized in its own directory with the following structure:
```
features/feature_name/
├── feature_screen.dart          # Main screen
├── feature_controller.dart       # Business logic
├── feature_provider.dart        # State management
└── widgets/                     # Feature-specific widgets
```

#### State Management Pattern
```dart
// Provider pattern for state management
class FeatureProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  List<Data> _data = [];

  // Getters
  bool get isLoading => _isLoading;
  List<Data> get data => _data;

  // Methods
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // API call
      _data = await service.getData();
    } catch (e) {
      // Error handling
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### API Service Pattern
```dart
class ApiService {
  static const String baseUrl = AppConfig.backendUrl;
  
  Future<Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await SessionManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
```

### UI/UX Guidelines

#### Design System
- **Colors**: Consistent color palette defined in `app_theme.dart`
- **Typography**: Google Fonts with defined text styles
- **Icons**: Lucide Icons for consistency
- **Spacing**: Standardized spacing system

#### Loading States
- **Shimmer Effects**: For content loading
- **Skeleton UI**: Placeholder content
- **Progress Indicators**: For long operations

#### Error Handling
- **User-Friendly Messages**: Clear error descriptions
- **Retry Mechanisms**: Automatic retry for network errors
- **Offline Support**: Graceful degradation

### Performance Optimization

#### Image Optimization
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

#### State Management Optimization
- Use `const` constructors where possible
- Implement `shouldRebuild` in custom widgets
- Minimize `setState` calls
- Use efficient state management patterns

#### Network Optimization
- Implement request caching
- Use pagination for large datasets
- Implement debouncing for search operations
- Add timeout handling

## 🧪 Testing

### Unit Testing
```dart
// Example test for a service
void main() {
  group('AuthService', () {
    test('should return user data on successful login', () async {
      // Test implementation
    });
  });
}
```

### Widget Testing
```dart
// Example widget test
void main() {
  testWidgets('Login screen shows form fields', (WidgetTester tester) async {
    await tester.pumpWidget(LoginScreen());
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
```

## 📦 Build & Deployment

### Android Build
```bash
# Generate APK
flutter build apk --release

# Generate App Bundle
flutter build appbundle --release
```

### iOS Build
```bash
# Generate iOS build
flutter build ios --release
```

### Web Build
```bash
# Generate web build
flutter build web --release
```

## 🔐 Security

### Token Management
- JWT tokens stored securely using `flutter_secure_storage`
- Automatic token refresh before expiration
- Secure token transmission over HTTPS

### Data Protection
- Sensitive data encrypted in local storage
- Network requests use HTTPS
- Input validation and sanitization

### Payment Security
- Stripe integration for secure payment processing
- No sensitive payment data stored locally
- PCI compliance through Stripe

## 📊 Analytics & Monitoring

### Error Tracking
- Comprehensive error logging
- User-friendly error messages
- Crash reporting (configurable)

### Performance Monitoring
- Network request timing
- App startup time
- Memory usage tracking

## 🔄 Version Control

### Git Workflow
- Feature branch development
- Pull request reviews
- Semantic versioning
- Automated testing on CI/CD

### Release Process
1. Feature development in feature branches
2. Code review and testing
3. Merge to development branch
4. Testing and bug fixes
5. Release to production

## 📚 Additional Resources

### Documentation Files
- `FLUTTER-BOOKING-IMPLEMENTATION-PLAN.md` - Detailed booking implementation
- `FLUTTER-BOOKING-REVIEW.md` - Booking system review
- `PAYMENT-ARCHITECTURE-SUMMARY.md` - Payment system architecture
- `TESTING_GUIDE.md` - Testing guidelines and examples

### External Dependencies
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)
- [HTTP Package](https://pub.dev/packages/http)

---

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Follow coding standards
4. Write tests for new features
5. Submit a pull request

### Code Standards
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for business logic
- Update documentation for new features

---

*Last Updated: [Current Date]*
*Version: 1.0.0* 