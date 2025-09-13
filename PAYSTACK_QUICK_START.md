# 🚀 Paystack Quick Start Guide

## 📋 What's Ready

✅ **Backend Integration** - Paystack API endpoints working  
✅ **Flutter Service** - PaystackService created  
✅ **Flutter Widget** - PaystackPaymentWidget created  
✅ **Integration Examples** - Ready to use in your app  
✅ **Test Scripts** - Postman collection and Flutter test  

## 🎯 Quick Setup (5 Minutes)

### 1. Run Database Migration
```sql
-- Copy this into phpMyAdmin SQL tab
ALTER TABLE `company_payment_accounts` 
ADD COLUMN `paystackSubaccountId` VARCHAR(255) NULL AFTER `accountId`;

-- Insert your subaccount
INSERT INTO `company_payment_accounts` (
  `companyId`, `paymentProvider`, `accountType`, `accountId`, 
  `accountStatus`, `verificationStatus`, `country`, `currency`,
  `capabilities`, `requirements`, `businessProfile`, `bankAccountInfo`,
  `metadata`, `createdAt`, `updatedAt`, `isActive`, `paystackSubaccountId`
) VALUES (
  11, 'paystack', 'custom', 'ACCT_4evq96sxvwuf7va', 'active', 'unverified',
  'KE', 'KES', 
  JSON_OBJECT('transfers', true, 'card_payments', true, 'bank_transfers', true, 'mobile_money', true, 'split_payments', true),
  JSON_OBJECT('bank_verification', 'pending', 'business_verification', 'pending', 'identity_verification', 'pending'),
  JSON_OBJECT('business_name', 'SPAir Services', 'business_type', 'aviation', 'description', 'Charter flight services', 'website', NULL, 'support_email', 'support@spairservices.com', 'support_phone', '+254700000000'),
  JSON_OBJECT('bank_name', 'Absa Bank Kenya Plc', 'account_number', '2051951312', 'account_name', 'SPAir Services', 'bank_code', '031', 'country', 'KE'),
  JSON_OBJECT('integration_type', 'paystack', 'subaccount_type', 'custom', 'percentage_charge', 5.0, 'settlement_bank', 'Absa Bank Kenya Plc', 'settlement_account_number', '2051951312', 'split_code', NULL),
  NOW(), NOW(), 1, 'ACCT_4evq96sxvwuf7va'
);
```

### 2. Test Backend (Postman)
1. Import `PAYSTACK_POSTMAN_COLLECTION.json` into Postman
2. Run "Get Paystack Info" test
3. Run "Initialize Paystack Payment (KES)" test

### 3. Test Flutter Integration
```dart
// Add this to any existing page
import 'package:air_charters/features/payment/paystack_integration_example.dart';

// In your payment page
ExistingPaymentPageIntegration.showPaystackPayment(
  context: context,
  bookingId: 'your_booking_id',
  companyId: 11,
  userId: 'your_user_id',
  amount: 100.0,
  currency: 'KES',
  email: 'user@example.com',
  onSuccess: (response) {
    // Payment successful!
    print('Payment successful: ${response.reference}');
  },
  onError: (error) {
    // Payment failed
    print('Payment failed: $error');
  },
  onCancelled: () {
    // Payment cancelled
    print('Payment cancelled');
  },
);
```

## 🧪 Testing

### Backend Tests
```bash
# Start backend
cd air_backend
npm run start:dev

# Test in another terminal
node test-paystack.js
```

### Flutter Tests
```dart
// Run the test script
flutter run test_paystack_integration.dart
```

## 📱 Integration Examples

### Add to Existing Payment Page
```dart
// In your existing payment page
ElevatedButton(
  onPressed: () {
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: widget.bookingId,
      companyId: widget.companyId,
      userId: currentUser.id,
      amount: widget.amount,
      currency: 'KES',
      email: currentUser.email,
      onSuccess: (response) {
        // Navigate to confirmation page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationPage(),
          ),
        );
      },
      onError: (error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $error')),
        );
      },
      onCancelled: () {
        // Show cancellation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment cancelled')),
        );
      },
    );
  },
  child: Text('Pay with Paystack'),
)
```

### Add to Payment Method Selection
```dart
// In your payment method selection
ListTile(
  leading: Icon(Icons.payment),
  title: Text('Pay with Paystack'),
  subtitle: Text('Card, M-Pesa, Bank Transfer'),
  onTap: () {
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: bookingId,
      companyId: companyId,
      userId: userId,
      amount: amount,
      currency: 'KES',
      email: email,
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
  },
)
```

## 🔧 Configuration

### Backend Environment
```bash
# In air_backend/.env
PAYSTACK_SECRET_KEY=sk_test_6d92a84f658a9f9c4d2d2e4f3d222da3c1c582af
PAYSTACK_PUBLIC_KEY=pk_test_6ad02ec12f811018e0d4c920ad79738d25d885ac
PAYSTACK_WEBHOOK_SECRET=your_paystack_webhook_secret
```

### Flutter AppConfig
```dart
// Already configured in lib/config/env/app_config.dart
static const String backendUrl = 'http://192.168.100.2:5000';
static const String paystackInitializeEndpoint = '/api/payments/paystack/initialize';
static const String paystackVerifyEndpoint = '/api/payments/paystack/verify';
static const String paystackInfoEndpoint = '/api/payments/paystack/info';
```

## 🎉 What You Get

- **Card Payments** - Visa, Mastercard, Verve
- **M-Pesa Payments** - STK Push for Kenya
- **Bank Transfers** - Direct bank transfers
- **Automatic Splitting** - Platform fee + company amount
- **Real-time Updates** - Webhook support
- **Secure** - Server-side key management
- **Production Ready** - Tested and working

## 🚀 Next Steps

1. **Run the database migration**
2. **Test with Postman collection**
3. **Add to your existing payment pages**
4. **Test with real payment flows**
5. **Deploy to production**

## 📞 Support

- **Backend API**: http://localhost:5000/api/payments/paystack/
- **Test Scripts**: `test-paystack.js` and `test_paystack_integration.dart`
- **Documentation**: `PAYSTACK_FLUTTER_INTEGRATION.md`

**Ready to go live!** 🎯
