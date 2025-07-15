# Clean Architecture Implementation Guide: Data/Domain/Presentation Layers per Feature

## Current vs. Proposed Architecture

### 🔴 Current Structure Issues
```
lib/
├── core/
│   ├── models/              # Models scattered in core
│   ├── providers/           # Providers in core (mixed responsibilities)
│   ├── services/            # Services in core
│   └── auth/               # Only auth has repository
├── features/
│   ├── auth/
│   │   ├── login_screen.dart           # Only presentation files
│   │   ├── signup_screen.dart          # No data/domain separation
│   │   └── verifycode.dart
│   ├── booking/
│   │   ├── booking_detail.dart         # Large files with mixed logic
│   │   └── confirm_booking.dart        # Business logic in UI
│   └── home/
│       └── home_screen.dart            # Single file per feature
```

**Problems:**
- ❌ Mixed responsibilities (UI logic + business logic + data access)
- ❌ Large files (login_screen.dart has 836 lines!)
- ❌ No clear separation of concerns
- ❌ Difficult to test individual layers
- ❌ Code reuse is limited
- ❌ Breaking changes in one layer affect others

### ✅ Proposed Clean Architecture Structure
```
lib/
├── core/                           # Shared across all features
│   ├── error/
│   ├── network/
│   ├── storage/
│   └── common/
│       ├── entities/               # Shared entities
│       ├── usecases/              # Shared use cases
│       └── repositories/          # Abstract repositories
├── features/
│   ├── auth/
│   │   ├── data/                  # Data Layer
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── auth_model.dart
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/                # Domain Layer
│   │   │   ├── entities/
│   │   │   │   ├── auth_entity.dart
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── signup_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── verify_code_usecase.dart
│   │   └── presentation/          # Presentation Layer
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── signup_page.dart
│   │       │   └── verify_code_page.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           ├── country_selector.dart
│   │           └── auth_button.dart
│   └── booking/
│       ├── data/
│       ├── domain/
│       └── presentation/
```

## 🏗️ Layer Responsibilities

### 1. **Data Layer** (`/data/`)
**Purpose:** Handle data retrieval, caching, and persistence

#### **DataSources** (`/data/datasources/`)
- **Remote DataSource**: API calls, network requests
- **Local DataSource**: Local storage, caching, offline data

#### **Models** (`/data/models/`)
- Data transfer objects (DTOs)
- JSON serialization/deserialization
- API response mapping

#### **Repository Implementation** (`/data/repositories/`)
- Concrete implementation of domain repositories
- Data source coordination
- Error handling and mapping

### 2. **Domain Layer** (`/domain/`)
**Purpose:** Core business logic, independent of frameworks

#### **Entities** (`/domain/entities/`)
- Core business objects
- No dependencies on external frameworks
- Pure Dart classes

#### **Repositories** (`/domain/repositories/`)
- Abstract contracts for data access
- Define what data is needed, not how to get it

#### **Use Cases** (`/domain/usecases/`)
- Single responsibility business operations
- Orchestrate data flow
- Contain business rules

### 3. **Presentation Layer** (`/presentation/`)
**Purpose:** UI components and state management

#### **Providers** (`/presentation/providers/`)
- State management specific to the feature
- UI state and business state coordination

#### **Pages** (`/presentation/pages/`)
- Full-screen UI components
- Route definitions

#### **Widgets** (`/presentation/widgets/`)
- Reusable UI components specific to the feature

## 📝 Implementation Steps

### Step 1: Create Feature Structure for Auth

```bash
# Create directory structure for auth feature
mkdir -p lib/features/auth/data/{datasources,models,repositories}
mkdir -p lib/features/auth/domain/{entities,repositories,usecases}
mkdir -p lib/features/auth/presentation/{providers,pages,widgets}
```

### Step 2: Domain Layer Implementation

#### **Auth Entity** (`lib/features/auth/domain/entities/auth_entity.dart`)
```dart
class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime expiresAt;
  final UserEntity user;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

#### **Auth Repository Interface** (`lib/features/auth/domain/repositories/auth_repository.dart`)
```dart
import 'package:either/either.dart';
import '../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String credential,
    required String password,
    required bool isEmail,
  });
  
  Future<Either<Failure, AuthEntity>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, AuthEntity>> refreshToken();
  
  Future<Either<Failure, AuthEntity>> verifyCode({
    required String email,
    required String code,
  });
}
```

#### **Login Use Case** (`lib/features/auth/domain/usecases/login_usecase.dart`)
```dart
import 'package:either/either.dart';
import '../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    return await repository.login(
      credential: params.credential,
      password: params.password,
      isEmail: params.isEmail,
    );
  }
}

class LoginParams {
  final String credential;
  final String password;
  final bool isEmail;

  LoginParams({
    required this.credential,
    required this.password,
    required this.isEmail,
  });
}
```

### Step 3: Data Layer Implementation

#### **Auth Model** (`lib/features/auth/data/models/auth_model.dart`)
```dart
import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.expiresIn,
    required super.expiresAt,
    required super.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] ?? 3600;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    return AuthModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: expiresIn,
      expiresAt: expiresAt,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': (user as UserModel).toJson(),
    };
  }
}
```

#### **Remote DataSource** (`lib/features/auth/data/datasources/auth_remote_datasource.dart`)
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_model.dart';
import '../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String credential,
    required String password,
    required bool isEmail,
  });
  
  Future<AuthModel> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });
  
  Future<void> logout();
  Future<AuthModel> refreshToken(String refreshToken);
  Future<AuthModel> verifyCode({required String email, required String code});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<AuthModel> login({
    required String credential,
    required String password,
    required bool isEmail,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'credential': credential,
        'password': password,
        'is_email': isEmail,
      }),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException(message: 'Login failed');
    }
  }

  // Implement other methods...
}
```

#### **Repository Implementation** (`lib/features/auth/data/repositories/auth_repository_impl.dart`)
```dart
import 'package:either/either.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/exceptions.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String credential,
    required String password,
    required bool isEmail,
  }) async {
    try {
      final authModel = await remoteDataSource.login(
        credential: credential,
        password: password,
        isEmail: isEmail,
      );
      
      // Cache auth data locally
      await localDataSource.cacheAuthData(authModel);
      
      return Right(authModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  // Implement other methods...
}
```

### Step 4: Presentation Layer Implementation

#### **Auth Provider** (`lib/features/auth/presentation/providers/auth_provider.dart`)
```dart
import 'package:flutter/foundation.dart';
import 'package:either/either.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../core/error/failures.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final LoginUsecase loginUsecase;
  final SignupUsecase signupUsecase;
  final LogoutUsecase logoutUsecase;

  AuthProvider({
    required this.loginUsecase,
    required this.signupUsecase,
    required this.logoutUsecase,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthEntity? _authData;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  AuthEntity? get authData => _authData;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> login({
    required String credential,
    required String password,
    required bool isEmail,
  }) async {
    _setStatus(AuthStatus.loading);

    final result = await loginUsecase(LoginParams(
      credential: credential,
      password: password,
      isEmail: isEmail,
    ));

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _setStatus(AuthStatus.error);
      },
      (authData) {
        _authData = authData;
        _setStatus(AuthStatus.authenticated);
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Login failed. Please try again.';
      case NetworkFailure:
        return 'No internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}
```

#### **Login Page** (`lib/features/auth/presentation/pages/login_page.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: LoginForm(),
          );
        },
      ),
    );
  }
}
```

### Step 5: Dependency Injection Setup

#### **Feature Dependencies** (`lib/features/auth/auth_dependencies.dart`)
```dart
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/signup_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'presentation/providers/auth_provider.dart';

class AuthDependencies {
  static List<Provider> getProviders() {
    return [
      // Data Sources
      Provider<AuthRemoteDataSource>(
        create: (_) => AuthRemoteDataSourceImpl(
          client: http.Client(),
          baseUrl: 'https://api.aircharters.com',
        ),
      ),
      Provider<AuthLocalDataSource>(
        create: (_) => AuthLocalDataSourceImpl(),
      ),

      // Repository
      ProxyProvider2<AuthRemoteDataSource, AuthLocalDataSource, AuthRepository>(
        update: (_, remote, local, __) => AuthRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: local,
        ),
      ),

      // Use Cases
      ProxyProvider<AuthRepository, LoginUsecase>(
        update: (_, repository, __) => LoginUsecase(repository),
      ),
      ProxyProvider<AuthRepository, SignupUsecase>(
        update: (_, repository, __) => SignupUsecase(repository),
      ),
      ProxyProvider<AuthRepository, LogoutUsecase>(
        update: (_, repository, __) => LogoutUsecase(repository),
      ),

      // Provider
      ProxyProvider3<LoginUsecase, SignupUsecase, LogoutUsecase, AuthProvider>(
        update: (_, login, signup, logout, __) => AuthProvider(
          loginUsecase: login,
          signupUsecase: signup,
          logoutUsecase: logout,
        ),
      ),
    ];
  }
}
```

## 🧪 Testing Benefits

### **Unit Testing Each Layer**
```dart
// Domain Layer Tests
void main() {
  group('LoginUsecase', () {
    late MockAuthRepository mockRepository;
    late LoginUsecase usecase;

    setUp(() {
      mockRepository = MockAuthRepository();
      usecase = LoginUsecase(mockRepository);
    });

    test('should return AuthEntity when login is successful', () async {
      // arrange
      when(mockRepository.login(any, any, any))
          .thenAnswer((_) async => Right(tAuthEntity));

      // act
      final result = await usecase(tLoginParams);

      // assert
      expect(result, Right(tAuthEntity));
      verify(mockRepository.login(
        credential: tLoginParams.credential,
        password: tLoginParams.password,
        isEmail: tLoginParams.isEmail,
      ));
    });
  });
}
```

## 📊 Migration Benefits

### **Before (Current Structure)**
- ❌ 836-line login screen with mixed responsibilities
- ❌ Direct API calls from UI
- ❌ Hard to test individual components
- ❌ Business logic scattered across files
- ❌ Tight coupling between layers

### **After (Clean Architecture)**
- ✅ Small, focused files with single responsibilities
- ✅ Clear separation of concerns
- ✅ Easy to test each layer independently
- ✅ Business logic centralized in use cases
- ✅ Loose coupling with dependency injection
- ✅ Easy to change data sources without affecting UI
- ✅ Scalable architecture for team development

## 🚀 Implementation Priority

### **Phase 1: Auth Feature** (1-2 weeks)
1. Create auth feature structure
2. Implement domain layer (entities, repositories, use cases)
3. Implement data layer (models, data sources, repository)
4. Refactor presentation layer
5. Set up dependency injection
6. Add comprehensive tests

### **Phase 2: Booking Feature** (1-2 weeks)
1. Apply same pattern to booking feature
2. Extract reusable patterns
3. Create feature templates

### **Phase 3: Remaining Features** (2-3 weeks)
1. Apply pattern to all remaining features
2. Refactor shared components
3. Optimize and document

## 🎯 Success Metrics

- **File Size**: Reduce large files (836 lines → ~100 lines per file)
- **Test Coverage**: Achieve 80%+ test coverage
- **Build Performance**: Improve compilation times
- **Developer Experience**: Faster feature development
- **Code Maintainability**: Clear responsibilities per layer
- **Team Collaboration**: Multiple developers can work on same feature

This clean architecture implementation will transform your Flutter app into a highly maintainable, testable, and scalable codebase that follows industry best practices.