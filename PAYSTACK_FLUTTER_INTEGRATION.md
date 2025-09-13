# 🚀 Paystack Flutter Integration Guide

## 📋 Overview
This guide shows how to integrate Paystack payments into your existing Air Charters Flutter app.

## 🔧 Files Created
- `lib/core/services/paystack_service.dart` - Paystack service
- `lib/shared/widgets/paystack_payment_widget.dart` - Payment UI widget
- `lib/features/payment/paystack_integration_example.dart` - Integration examples

## 🎯 Integration Steps

### 1. Add to Existing Payment Page

```dart
import 'package:air_charters/features/payment/paystack_integration_example.dart';

// In your existing payment page
class PaymentPage extends StatefulWidget {
  final String bookingId;
  final int companyId;
  final double amount;
  final String currency;
  
  // ... existing code
}

class _PaymentPageState extends State<PaymentPage> {
  // ... existing code
  
  void _showPaystackPayment() {
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: widget.bookingId,
      companyId: widget.companyId,
      userId: currentUser.id, // Get from your auth system
      amount: widget.amount,
      currency: widget.currency,
      email: currentUser.email, // Get from your auth system
      onSuccess: (response) {
        // Handle successful payment
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationPage(
              bookingId: widget.bookingId,
              paymentReference: response.reference,
            ),
          ),
        );
      },
      onError: (error) {
        // Handle payment error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onCancelled: () {
        // Handle cancellation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... your existing UI
      
      // Add Paystack payment button
      ElevatedButton(
        onPressed: _showPaystackPayment,
        child: Text('Pay with Paystack'),
      ),
    );
  }
}
```

### 2. Add to Existing Payment Method Selection

```dart
// In your payment method selection widget
class PaymentMethodSelection extends StatelessWidget {
  final String bookingId;
  final int companyId;
  final double amount;
  final String currency;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... existing payment methods
        
        // Add Paystack option
        _buildPaymentOption(
          icon: Icons.payment,
          title: 'Pay with Paystack',
          subtitle: 'Card, M-Pesa, Bank Transfer',
          onTap: () => _showPaystackPayment(),
        ),
      ],
    );
  }
  
  void _showPaystackPayment() {
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: bookingId,
      companyId: companyId,
      userId: currentUser.id,
      amount: amount,
      currency: currency,
      email: currentUser.email,
      preferredPaymentMethod: 'card', // or 'mpesa'
      onSuccess: (response) {
        // Handle success
      },
      onError: (error) {
        // Handle error
      },
      onCancelled: () {
        // Handle cancellation
      },
    );
  }
}
```

### 3. Direct Service Usage

```dart
import 'package:air_charters/core/services/paystack_service.dart';

class PaymentService {
  final PaystackService _paystackService = PaystackService();
  
  Future<void> processPayment({
    required String bookingId,
    required int companyId,
    required String userId,
    required double amount,
    required String currency,
    required String email,
    required String paymentMethod, // 'card' or 'mpesa'
  }) async {
    try {
      PaystackResponse response;
      
      if (paymentMethod == 'card') {
        response = await _paystackService.processCardPayment(
          amount: amount,
          currency: currency,
          email: email,
          bookingId: bookingId,
          companyId: companyId,
          userId: userId,
        );
      } else if (paymentMethod == 'mpesa') {
        response = await _paystackService.processMpesaPayment(
          amount: amount,
          currency: currency,
          email: email,
          phoneNumber: currentUser.phoneNumber, // Get from user profile
          bookingId: bookingId,
          companyId: companyId,
          userId: userId,
        );
      }
      
      if (response.isSuccess) {
        // Payment successful
        await _updateBookingStatus(bookingId, 'paid');
        await _navigateToConfirmation(response.reference);
      } else if (response.isCancelled) {
        // Payment cancelled
        _showCancellationMessage();
      } else {
        // Payment failed
        _showErrorMessage(response.message ?? 'Payment failed');
      }
    } catch (e) {
      _showErrorMessage('Payment error: $e');
    }
  }
}
```

## 🎨 Customizing the UI

### Custom Payment Widget

```dart
// Create your own custom payment widget
class CustomPaystackPayment extends StatelessWidget {
  final String bookingId;
  final int companyId;
  final double amount;
  final String currency;
  
  @override
  Widget build(BuildContext context) {
    return PaystackPaymentWidget(
      bookingId: bookingId,
      companyId: companyId,
      userId: currentUser.id,
      amount: amount,
      currency: currency,
      email: currentUser.email,
      // Customize the appearance
      buttonText: 'Complete Payment',
      buttonColor: Colors.blue,
      buttonTextColor: Colors.white,
      onPaymentSuccess: (response) {
        // Your custom success handling
      },
      onPaymentError: (error) {
        // Your custom error handling
      },
      onPaymentCancelled: () {
        // Your custom cancellation handling
      },
    );
  }
}
```

## 🔧 Configuration

### Update AppConfig

```dart
// lib/config/env/app_config.dart
class AppConfig {
  // ... existing config
  
  // Backend URL (already configured)
  static const String backendUrl = 'http://192.168.100.2:5000';
  
  // Paystack API Endpoints (already configured)
  static const String paystackInitializeEndpoint = '/api/payments/paystack/initialize';
  static const String paystackVerifyEndpoint = '/api/payments/paystack/verify';
  static const String paystackInfoEndpoint = '/api/payments/paystack/info';
  
  // Helper methods
  static String get baseUrl => backendUrl;
  static String get authToken => ''; // Implement based on your auth system
}
```

## 🧪 Testing

### Test Payment Flow

```dart
// Test the payment flow
class PaymentTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Paystack Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _testCardPayment(),
              child: Text('Test Card Payment'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _testMpesaPayment(),
              child: Text('Test M-Pesa Payment'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _testCardPayment() {
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: 'test_booking_123',
      companyId: 11,
      userId: 'test_user_456',
      amount: 100.0,
      currency: 'KES',
      email: 'test@example.com',
      preferredPaymentMethod: 'card',
      onSuccess: (response) => print('Card payment success: ${response.reference}'),
      onError: (error) => print('Card payment error: $error'),
      onCancelled: () => print('Card payment cancelled'),
    );
  }
  
  void _testMpesaPayment() {
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: 'test_booking_456',
      companyId: 11,
      userId: 'test_user_456',
      amount: 100.0,
      currency: 'KES',
      email: 'test@example.com',
      preferredPaymentMethod: 'mpesa',
      onSuccess: (response) => print('M-Pesa payment success: ${response.reference}'),
      onError: (error) => print('M-Pesa payment error: $error'),
      onCancelled: () => print('M-Pesa payment cancelled'),
    );
  }
}
```

## 📱 Integration Checklist

- [ ] Import PaystackService and PaystackPaymentWidget
- [ ] Add payment method selection UI
- [ ] Implement success/error/cancellation handlers
- [ ] Test with real Paystack test keys
- [ ] Update booking status after successful payment
- [ ] Navigate to confirmation page
- [ ] Handle payment failures gracefully
- [ ] Add loading states and error messages

## 🚀 Production Deployment

1. **Update backend URL** in AppConfig for production
2. **Use production Paystack keys** in backend environment
3. **Test with real payment flows**
4. **Set up webhooks** in Paystack dashboard
5. **Monitor payment success rates**

## 📞 Support

- **Backend API**: http://localhost:5000/api/payments/paystack/
- **Paystack Documentation**: https://paystack.com/docs
- **Flutter Paystack SDK**: https://pub.dev/packages/paystack_flutter_sdk

## 🎯 Next Steps

1. **Run the database migration** to add Paystack fields
2. **Test the Postman collection** to verify backend
3. **Integrate into your existing payment pages**
4. **Test with real payment flows**
5. **Deploy to production**

The Paystack integration is ready to use! 🎉
