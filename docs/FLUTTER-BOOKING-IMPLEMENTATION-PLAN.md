# Flutter Booking System Implementation Plan

## 🎯 Overview

This document outlines the step-by-step implementation plan to align the Flutter app with our updated backend booking system, including Stripe integration, user-as-passenger enhancement, and unified payment flow.

## 📋 Implementation Phases

### **Phase 1: Core API Integration (Week 1)**

#### **1.1 Update Booking Service**
**File**: `lib/core/services/booking_service.dart`

**Changes Required:**
```dart
class BookingService {
  // Add new method for booking with payment intent
  Future<BookingWithPaymentIntent> createBookingWithPaymentIntent(BookingModel booking) async {
    try {
      final response = await _apiClient.post('/api/bookings', booking.toCreateJson());
      
      if (response['success'] == true && response['data'] != null) {
        return BookingWithPaymentIntent.fromJson(response['data']);
      }
      
      throw ServerException('Failed to create booking with payment intent');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to create booking: ${e.toString()}');
    }
  }
  
  // Add new method for unified payment processing
  Future<BookingModel> processPayment(String bookingId, String transactionId, String paymentMethod) async {
    try {
      final response = await _apiClient.post('/api/bookings/$bookingId/process-payment', {
        'paymentTransactionId': transactionId,
        'paymentMethod': paymentMethod,
      });
      
      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }
      
      throw ServerException('Failed to process payment');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to process payment: ${e.toString()}');
    }
  }
}
```

#### **1.2 Create New Models**
**File**: `lib/core/models/booking_with_payment_intent.dart`

```dart
class BookingWithPaymentIntent {
  final BookingModel booking;
  final PaymentIntent? paymentIntent;
  final PaymentInstructions paymentInstructions;
  
  BookingWithPaymentIntent({
    required this.booking,
    this.paymentIntent,
    required this.paymentInstructions,
  });
  
  factory BookingWithPaymentIntent.fromJson(Map<String, dynamic> json) {
    return BookingWithPaymentIntent(
      booking: BookingModel.fromJson(json['booking']),
      paymentIntent: json['paymentIntent'] != null 
          ? PaymentIntent.fromJson(json['paymentIntent']) 
          : null,
      paymentInstructions: PaymentInstructions.fromJson(json['paymentInstructions']),
    );
  }
}

class PaymentIntent {
  final String id;
  final String clientSecret;
  final String status;
  final bool requiresAction;
  final Map<String, dynamic>? nextAction;
  
  PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
    required this.requiresAction,
    this.nextAction,
  });
  
  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'],
      clientSecret: json['clientSecret'],
      status: json['status'],
      requiresAction: json['requiresAction'] ?? false,
      nextAction: json['nextAction'],
    );
  }
}

class PaymentInstructions {
  final double amount;
  final String currency;
  final List<String> paymentMethods;
  final List<String> nextSteps;
  final Map<String, String> apiEndpoints;
  
  PaymentInstructions({
    required this.amount,
    required this.currency,
    required this.paymentMethods,
    required this.nextSteps,
    required this.apiEndpoints,
  });
  
  factory PaymentInstructions.fromJson(Map<String, dynamic> json) {
    return PaymentInstructions(
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      paymentMethods: List<String>.from(json['paymentMethods']),
      nextSteps: List<String>.from(json['nextSteps']),
      apiEndpoints: Map<String, String>.from(json['apiEndpoints']),
    );
  }
}
```

#### **1.3 Update Booking Provider**
**File**: `lib/core/providers/booking_provider.dart`

```dart
class BookingProvider with ChangeNotifier {
  // Add new method for booking with payment intent
  Future<BookingWithPaymentIntent?> createBookingWithPaymentIntent(BookingModel booking) async {
    try {
      _state = BookingState.creating;
      _errorMessage = null;
      notifyListeners();

      final result = await _bookingService.createBookingWithPaymentIntent(booking);

      // Add to local list
      _bookings.insert(0, result.booking);
      _currentBooking = result.booking;

      _state = BookingState.loaded;
      notifyListeners();

      return result;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }
  
  // Add new method for payment processing
  Future<bool> processPayment(String bookingId, String transactionId, String paymentMethod) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _bookingService.processPayment(bookingId, transactionId, paymentMethod);

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = updatedBooking;
      }

      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = updatedBooking;
      }

      _state = BookingState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
```

### **Phase 2: Passenger Management Updates (Week 1)**

#### **2.1 Update Passenger Provider**
**File**: `lib/core/providers/passengers_provider.dart`

```dart
class PassengerProvider with ChangeNotifier {
  // Update initialization to not add user automatically
  void initializeForBooking({UserModel? currentUser}) {
    _isLocalMode = true;
    _state = PassengerState.loaded;
    _errorMessage = null;
    _passengers.clear();
    _currentBookingId = null;
    
    // Don't add user automatically - backend will handle this
    // Only add additional passengers if any
    
    notifyListeners();
  }
  
  // Add method to get primary passenger (user)
  PassengerModel? get primaryPassenger {
    return _passengers.firstWhere(
      (p) => p.isUser == true,
      orElse: () => null,
    );
  }
  
  // Add method to get additional passengers
  List<PassengerModel> get additionalPassengers {
    return _passengers.where((p) => p.isUser != true).toList();
  }
}
```

#### **2.2 Update Passenger Model**
**File**: `lib/core/models/passenger_model.dart`

```dart
class PassengerModel {
  final int? id;
  final String bookingId;
  final String firstName;
  final String lastName;
  final int? age;
  final String? nationality;
  final String? idPassportNumber;
  final bool isUser; // Add isUser field
  final DateTime createdAt;
  
  PassengerModel({
    this.id,
    required this.bookingId,
    required this.firstName,
    required this.lastName,
    this.age,
    this.nationality,
    this.idPassportNumber,
    this.isUser = false, // Default to false
    required this.createdAt,
  });
  
  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['id'],
      bookingId: json['bookingId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      nationality: json['nationality'],
      idPassportNumber: json['idPassportNumber'],
      isUser: json['isUser'] ?? false, // Parse isUser field
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'nationality': nationality,
      'idPassportNumber': idPassportNumber,
      'isUser': isUser, // Include isUser field
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  PassengerModel copyWith({
    int? id,
    String? bookingId,
    String? firstName,
    String? lastName,
    int? age,
    String? nationality,
    String? idPassportNumber,
    bool? isUser,
    DateTime? createdAt,
  }) {
    return PassengerModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      idPassportNumber: idPassportNumber ?? this.idPassportNumber,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### **Phase 3: Stripe Integration (Week 2)**

#### **3.1 Add Stripe Dependencies**
**File**: `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Add Stripe dependencies
  flutter_stripe: ^10.0.0
  stripe_platform_interface: ^8.0.0
```

#### **3.2 Create Stripe Service**
**File**: `lib/core/services/stripe_service.dart`

```dart
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/payment_intent.dart';

class StripeService {
  static const String _publishableKey = 'your_publishable_key_here';
  
  static Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }
  
  static Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String currency,
    required String bookingId,
  }) async {
    // This would typically call your backend to create a payment intent
    // For now, we'll use the payment intent from the booking creation
    throw UnimplementedError('Payment intent creation should be handled by backend');
  }
  
  static Future<PaymentResult> confirmPayment({
    required String clientSecret,
    required PaymentMethodParams paymentMethodParams,
  }) async {
    try {
      final result = await Stripe.instance.confirmPayment(
        clientSecret,
        paymentMethodParams,
      );
      
      return PaymentResult(
        status: result.status,
        paymentIntentId: result.paymentIntentId,
        error: result.error,
      );
    } catch (e) {
      return PaymentResult(
        status: PaymentStatus.failed,
        error: e.toString(),
      );
    }
  }
  
  static Future<PaymentMethod> createPaymentMethod({
    required PaymentMethodParams params,
  }) async {
    try {
      return await Stripe.instance.createPaymentMethod(params);
    } catch (e) {
      throw Exception('Failed to create payment method: $e');
    }
  }
}

class PaymentResult {
  final PaymentStatus status;
  final String? paymentIntentId;
  final String? error;
  
  PaymentResult({
    required this.status,
    this.paymentIntentId,
    this.error,
  });
  
  bool get isSuccess => status == PaymentStatus.succeeded;
  bool get isFailed => status == PaymentStatus.failed;
  bool get requiresAction => status == PaymentStatus.requiresAction;
}

enum PaymentStatus {
  succeeded,
  failed,
  requiresAction,
  canceled,
}
```

### **Phase 4: UI Updates (Week 2-3)**

#### **4.1 Update Review Trip Page**
**File**: `lib/features/booking/review_trip.dart`

```dart
class _ReviewTripPageState extends State<ReviewTripPage> {
  // Add payment intent state
  BookingWithPaymentIntent? _bookingWithPaymentIntent;
  bool _isCreatingBooking = false;
  
  // Update booking creation method
  Future<void> _showPaymentConfirmation() async {
    setState(() {
      _isCreatingBooking = true;
    });
    
    try {
      // Calculate pricing
      final basePrice = widget.price;
      final diningCost = _onboardDining ? 150.0 : 0.0;
      final transportationCost = _groundTransportation ? 200.0 : 0.0;
      final taxes = (basePrice + diningCost + transportationCost) * 0.12;
      final totalPrice = basePrice + diningCost + transportationCost + taxes;

      // Get additional passengers from provider (user will be added by backend)
      final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
      final additionalPassengers = passengerProvider.additionalPassengers;

      // Parse payment method
      PaymentMethod? paymentMethod;
      if (_selectedPaymentMethod.contains('Card')) {
        paymentMethod = PaymentMethod.card;
      } else if (_selectedPaymentMethod.contains('MPesa')) {
        paymentMethod = PaymentMethod.mpesa;
      } else if (_selectedPaymentMethod.contains('Wallet')) {
        paymentMethod = PaymentMethod.wallet;
      }

      // Create booking with payment intent
      final bookingController = Provider.of<BookingController>(context, listen: false);
      final result = await bookingController.createBookingWithPaymentIntent(
        dealId: widget.deal?.id ?? 0,
        totalPrice: totalPrice,
        onboardDining: _onboardDining,
        groundTransportation: _groundTransportation,
        billingRegion: _selectedBillingRegion,
        paymentMethod: paymentMethod,
        additionalPassengers: additionalPassengers, // Only additional passengers
      );

      if (result.isSuccess && result.bookingWithPaymentIntent != null) {
        _bookingWithPaymentIntent = result.bookingWithPaymentIntent;
        
        // Navigate to payment page with payment intent
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                bookingWithPaymentIntent: _bookingWithPaymentIntent!,
              ),
            ),
          );
        }
      } else {
        // Show error dialog
        if (mounted) {
          _showErrorDialog(result.errorMessage ?? 'Failed to create booking. Please try again.');
        }
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        _showErrorDialog('An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
      }
    }
  }
  
  // Update passengers section to show primary passenger
  Widget _buildPassengersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary passenger (user) - read-only
        _buildPrimaryPassengerCard(),
        
        // Additional passengers
        _buildAdditionalPassengersList(),
        
        // Add passenger button (for additional passengers only)
        _buildAddPassengerButton(),
      ],
    );
  }
  
  Widget _buildPrimaryPassengerCard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary Passenger (You)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Primary',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### **4.2 Create Payment Page**
**File**: `lib/features/booking/payment/payment_page.dart`

```dart
class PaymentPage extends StatefulWidget {
  final BookingWithPaymentIntent bookingWithPaymentIntent;
  
  const PaymentPage({
    super.key,
    required this.bookingWithPaymentIntent,
  });
  
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessingPayment = false;
  String? _paymentError;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Payment',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentAmountCard(),
            const SizedBox(height: 24),
            _buildStripePaymentForm(),
            const SizedBox(height: 24),
            _buildPaymentButton(),
            if (_paymentError != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Amount',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
              Text(
                '\$${widget.bookingWithPaymentIntent.paymentInstructions.amount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStripePaymentForm() {
    if (widget.bookingWithPaymentIntent.paymentIntent == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB74D)),
        ),
        child: Column(
          children: [
            const Icon(Icons.warning, color: Color(0xFFE65100)),
            const SizedBox(height: 8),
            Text(
              'Payment Intent Not Available',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact support to complete your payment.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFE65100),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Stripe Card Field
          CardFormField(
            style: CardFormStyle(
              borderColor: const Color(0xFFE9ECEF),
              borderRadius: 12,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E5E5),
          disabledForegroundColor: const Color(0xFF888888),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Pay \$${widget.bookingWithPaymentIntent.paymentInstructions.amount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
  
  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
      _paymentError = null;
    });
    
    try {
      // Get payment method from Stripe
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      // Confirm payment with Stripe
      final result = await Stripe.instance.confirmPayment(
        widget.bookingWithPaymentIntent.paymentIntent!.clientSecret,
        PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            paymentMethodId: paymentMethod.id,
          ),
        ),
      );
      
      if (result.status == PaymentStatus.succeeded) {
        // Process payment with backend
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        final success = await bookingProvider.processPayment(
          widget.bookingWithPaymentIntent.booking.id!,
          result.paymentIntentId!,
          'card',
        );
        
        if (success) {
          // Navigate to success page
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingSuccessPage(
                  booking: widget.bookingWithPaymentIntent.booking,
                ),
              ),
            );
          }
        } else {
          setState(() {
            _paymentError = 'Failed to process payment. Please try again.';
          });
        }
      } else {
        setState(() {
          _paymentError = 'Payment failed: ${result.error?.message ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _paymentError = 'Payment error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }
  
  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Color(0xFFD32F2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _paymentError!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### **Phase 5: Testing & Validation (Week 3)**

#### **5.1 Unit Tests**
**File**: `test/core/services/booking_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/services/booking_service.dart';

void main() {
  group('BookingService', () {
    test('createBookingWithPaymentIntent should return BookingWithPaymentIntent', () async {
      // Test implementation
    });
    
    test('processPayment should return updated booking', () async {
      // Test implementation
    });
  });
}
```

#### **5.2 Integration Tests**
**File**: `test/integration/booking_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/main.dart';

void main() {
  testWidgets('Complete booking flow test', (WidgetTester tester) async {
    // Test complete booking flow
  });
}
```

## 📋 **Implementation Checklist**

### **Week 1: Core API Integration**
- [q ] Update BookingService with new methods
- [ ] Create BookingWithPaymentIntent model
- [ ] Update BookingProvider
- [ ] Update PassengerProvider (remove auto user addition)
- [ ] Update PassengerModel (add isUser field)
- [ ] Test API integration

### **Week 2: Stripe Integration**
- [ ] Add Stripe dependencies
- [ ] Create StripeService
- [ ] Initialize Stripe in main.dart
- [ ] Test Stripe integration
- [ ] Update ReviewTripPage
- [ ] Create PaymentPage

### **Week 3: UI Updates & Testing**
- [ ] Update BookingConfirmationPage
- [ ] Update PassengerListWidget
- [ ] Add payment intent UI components
- [ ] Add comprehensive testing
- [ ] Fix bugs and issues
- [ ] Performance optimization

## 🚀 **Deployment Steps**

### **1. Pre-deployment**
- [ ] Run all tests
- [ ] Update environment variables
- [ ] Configure Stripe keys
- [ ] Test with backend

### **2. Deployment**
- [ ] Build release version
- [ ] Deploy to app stores
- [ ] Monitor for issues
- [ ] Collect user feedback

### **3. Post-deployment**
- [ ] Monitor analytics
- [ ] Track booking success rates
- [ ] Monitor payment success rates
- [ ] Address user feedback

## 📊 **Success Metrics**

### **Technical Metrics**
- [ ] 100% API integration success
- [ ] 0% payment processing errors
- [ ] <2s booking creation time
- [ ] <5s payment processing time

### **User Experience Metrics**
- [ ] Reduced booking abandonment
- [ ] Increased payment success rate
- [ ] Improved user satisfaction
- [ ] Faster booking completion

## 🔧 **Troubleshooting Guide**

### **Common Issues**
1. **Payment Intent Creation Fails**
   - Check Stripe configuration
   - Verify backend payment intent creation
   - Check network connectivity

2. **User Not Added as Passenger**
   - Verify backend user-as-passenger logic
   - Check user authentication
   - Verify API response format

3. **Payment Processing Fails**
   - Check Stripe client secret
   - Verify payment method data
   - Check backend payment processing

### **Debug Steps**
1. Enable debug logging
2. Check API responses
3. Verify Stripe integration
4. Test with sample data
5. Monitor error logs

---

**Status**: 📋 **IMPLEMENTATION READY**
**Priority**: 🚨 **HIGH**
**Estimated Timeline**: 3 weeks
**Risk Level**: 🟡 **MEDIUM** (with proper testing) 