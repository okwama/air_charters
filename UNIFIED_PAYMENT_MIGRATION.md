# Unified Payment System Migration Guide

## Overview

The Flutter app has been updated to use the new unified payment system that provides:
- **Automatic company routing** based on deal configurations
- **Split payments** (platform fee + company amount)
- **Transaction ledger** for full audit trail
- **Automatic provider selection** (Stripe Connect or M-Pesa Merchant)

## Key Changes Made

### 1. New Payment Models (`lib/core/models/payment_models.dart`)

Added new models to support the unified payment system:

```dart
// Unified payment request/response
class UnifiedPaymentRequest
class UnifiedPaymentResponse

// Transaction ledger for audit trail
class TransactionLedgerEntry

// Company payment account management
class CompanyPaymentAccount
class PaymentProviderInfo
```

### 2. Updated Booking Service (`lib/core/services/booking_service.dart`)

**New Methods:**
- `processUnifiedPayment()` - Main unified payment processing
- `getTransactionDetails()` - Get transaction details from ledger
- `getCompanyTransactions()` - Get company-specific transactions
- `getAvailablePaymentProviders()` - Get available payment providers
- `getCompanyPaymentAccounts()` - Get company payment accounts

**Legacy Methods (Deprecated):**
- `processPayment()` - Still available for backward compatibility

### 3. Updated Booking Provider (`lib/core/providers/booking_provider.dart`)

**New Methods:**
- `processUnifiedPayment()` - Unified payment processing with state management
- `getTransactionDetails()` - Transaction details with loading states
- `getCompanyTransactions()` - Company transactions with error handling
- `getAvailablePaymentProviders()` - Payment provider information
- `getCompanyPaymentAccounts()` - Company account management

### 4. Updated Payment Controller (`lib/core/controllers/payment.controller/payment_controller.dart`)

**New Methods:**
- `processUnifiedPayment()` - Main payment processing with validation
- `UnifiedPaymentResult` - New result class with detailed payment information

**Legacy Methods (Deprecated):**
- `processBookingPayment()` - Still available for backward compatibility

### 5. Updated Payment Screen (`lib/features/booking/payment/payment_screen.dart`)

**Changes:**
- Replaced `completePayment()` with `processUnifiedPayment()`
- Added detailed logging for unified payment results
- Enhanced error handling with unified payment responses

## API Endpoints

### New Unified Payment Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/unified-payments/process` | POST | Process payment with automatic routing |
| `/api/unified-payments/transaction/{id}` | GET | Get transaction details |
| `/api/unified-payments/company/{id}/transactions` | GET | Get company transactions |
| `/api/unified-payments/providers` | GET | Get available providers |
| `/api/unified-payments/company-accounts` | GET | Get company accounts |

### Legacy Endpoints (Still Supported)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/bookings/{id}/process-payment` | POST | Legacy payment processing |
| `/api/payments/create-intent` | POST | Create payment intent |
| `/api/payments/confirm` | POST | Confirm payment |

## Usage Examples

### 1. Process Unified Payment

```dart
final bookingProvider = context.read<BookingProvider>();

// Process payment using unified system
final result = await bookingProvider.processUnifiedPayment(
  bookingId: 'booking_123',
  paymentIntentId: 'pi_1234567890',
  paymentMethodId: 'pm_1234567890',
);

if (result != null) {
  print('Payment successful!');
  print('Transaction ID: ${result.transactionId}');
  print('Provider: ${result.paymentProvider}');
  print('Company: ${result.companyName}');
  print('Total: ${result.totalAmount}');
  print('Platform Fee: ${result.platformFee}');
  print('Company Amount: ${result.companyAmount}');
} else {
  print('Payment failed: ${bookingProvider.errorMessage}');
}
```

### 2. Get Transaction Details

```dart
final result = await bookingProvider.getTransactionDetails('txn_1234567890');

if (result != null) {
  print('Transaction: ${result.transactionId}');
  print('Status: ${result.status}');
  print('Ledger Entries: ${result.ledgerEntries.length}');
}
```

### 3. Get Company Transactions

```dart
final transactions = await bookingProvider.getCompanyTransactions('company_123');

for (final transaction in transactions) {
  print('Transaction: ${transaction.transactionId}');
  print('Amount: ${transaction.amount}');
  print('Type: ${transaction.transactionType}');
  print('Status: ${transaction.status}');
}
```

### 4. Get Available Providers

```dart
final providers = await bookingProvider.getAvailablePaymentProviders();

for (final provider in providers) {
  print('Provider: ${provider.name}');
  print('Type: ${provider.type}');
  print('Available: ${provider.isAvailable}');
}
```

## Payment Flow

### New Unified Payment Flow

1. **Create Booking with Payment Intent**
   ```dart
   final bookingWithIntent = await bookingProvider.createBookingWithPaymentIntent(booking);
   ```

2. **Process Payment (Unified System)**
   ```dart
   final result = await bookingProvider.processUnifiedPayment(
     bookingId: booking.id!,
     paymentIntentId: paymentIntent.id,
   );
   ```

3. **Automatic Processing**
   - System determines company from booking
   - Selects appropriate payment provider (Stripe Connect/M-Pesa Merchant)
   - Calculates platform fee and company amount
   - Creates transaction ledger entries
   - Routes payment to company account

### Legacy Payment Flow (Deprecated)

1. **Create Payment Intent**
   ```dart
   final paymentIntent = await bookingProvider.createPaymentIntent(...);
   ```

2. **Process Payment (Legacy)**
   ```dart
   final success = await bookingProvider.processPayment(
     bookingId: booking.id!,
     transactionId: transactionId,
     paymentMethod: 'card',
   );
   ```

## Benefits of Unified Payment System

### 1. Automatic Company Routing
- No manual provider selection required
- System automatically routes to correct company account
- Supports multiple companies with different payment providers

### 2. Split Payment Processing
- Platform fee automatically calculated and deducted
- Company amount automatically routed to company account
- Transparent fee structure

### 3. Transaction Ledger
- Complete audit trail of all financial transactions
- Detailed breakdown of fees, taxes, and amounts
- Support for complex payment scenarios

### 4. Provider Flexibility
- Automatic selection between Stripe Connect and M-Pesa Merchant
- Easy addition of new payment providers
- Consistent API regardless of underlying provider

## Migration Checklist

### ✅ Completed
- [x] Added unified payment models
- [x] Updated booking service with unified methods
- [x] Updated booking provider with unified methods
- [x] Updated payment controller with unified methods
- [x] Updated payment screen to use unified system
- [x] Maintained backward compatibility
- [x] Added comprehensive error handling
- [x] Added detailed logging

### 🔄 Recommended Next Steps
- [ ] Update UI to display split payment information
- [ ] Add transaction ledger viewing screens
- [ ] Implement company payment account management
- [ ] Add payment provider selection UI (if needed)
- [ ] Update payment history to show unified transactions
- [ ] Add transaction receipt generation

## Testing

### Test Scenarios

1. **Successful Unified Payment**
   - Create booking
   - Process payment with unified system
   - Verify transaction ledger entries
   - Confirm company routing

2. **Error Handling**
   - Test with invalid payment intent
   - Test with missing company account
   - Test with provider failures

3. **Backward Compatibility**
   - Test legacy payment methods still work
   - Verify no breaking changes to existing flows

### Test Data

```dart
// Test booking data
final testBooking = BookingModel(
  id: 'test_booking_123',
  dealId: 1,
  totalPrice: 1000.0,
  // ... other fields
);

// Test payment intent
final testPaymentIntent = PaymentIntentModel(
  id: 'pi_test_123',
  clientSecret: 'pi_test_123_secret_456',
  amount: 1000.0,
  currency: 'USD',
);
```

## Troubleshooting

### Common Issues

1. **"Failed to process unified payment"**
   - Check if company has payment account configured
   - Verify payment intent is valid
   - Check backend logs for detailed error

2. **"Company not found"**
   - Ensure booking has valid company ID
   - Verify company payment account exists
   - Check company payment account is active

3. **"Payment provider not available"**
   - Check available payment providers
   - Verify company payment account configuration
   - Check provider-specific error messages

### Debug Information

The unified payment system provides detailed logging:

```dart
print('=== UNIFIED PAYMENT PROCESSING ===');
print('Booking ID: $bookingId');
print('Payment Intent ID: $paymentIntentId');
print('Company ID: $companyId');
print('Provider: $provider');
print('Amount: $amount');
print('Platform Fee: $platformFee');
print('Company Amount: $companyAmount');
```

## Support

For issues with the unified payment system:

1. Check the backend logs for detailed error information
2. Verify all required models and services are properly imported
3. Ensure the backend unified payment endpoints are working
4. Test with the provided Postman collection

## Future Enhancements

1. **Real-time Payment Status**
   - WebSocket integration for live payment updates
   - Push notifications for payment status changes

2. **Advanced Analytics**
   - Payment performance metrics
   - Company revenue analytics
   - Platform fee analytics

3. **Multi-currency Support**
   - Dynamic currency conversion
   - Local currency display
   - Exchange rate management

4. **Payment Scheduling**
   - Recurring payments
   - Payment reminders
   - Automatic retry logic

