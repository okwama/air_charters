import 'package:flutter/material.dart';
import 'package:air_charters/core/services/paystack_service.dart';
import 'package:air_charters/features/payment/paystack_integration_example.dart';

/// Test script to verify Paystack integration in Flutter
/// Run this to test the payment flow
void main() {
  runApp(PaystackTestApp());
}

class PaystackTestApp extends StatelessWidget {
  const PaystackTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paystack Integration Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PaystackTestPage(),
    );
  }
}

class PaystackTestPage extends StatefulWidget {
  const PaystackTestPage({super.key});

  @override
  _PaystackTestPageState createState() => _PaystackTestPageState();
}

class _PaystackTestPageState extends State<PaystackTestPage> {
  final PaystackService _paystackService = PaystackService();
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paystack Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Results
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Click a test button to run tests...' : _testResults,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Test Buttons
            _buildTestButton(
              'Test Backend Connection',
              _testBackendConnection,
              Colors.blue,
            ),
            
            SizedBox(height: 8),
            
            _buildTestButton(
              'Test Payment Initialization',
              _testPaymentInitialization,
              Colors.green,
            ),
            
            SizedBox(height: 8),
            
            _buildTestButton(
              'Test Card Payment Widget',
              _testCardPaymentWidget,
              Colors.orange,
            ),
            
            SizedBox(height: 8),
            
            _buildTestButton(
              'Test M-Pesa Payment Widget',
              _testMpesaPaymentWidget,
              Colors.purple,
            ),
            
            SizedBox(height: 16),
            
            // Loading Indicator
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults += '${DateTime.now().toString().substring(11, 19)}: $result\n';
    });
  }

  void _clearTestResults() {
    setState(() {
      _testResults = '';
    });
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _clearTestResults();
    });

    try {
      _addTestResult('Testing backend connection...');
      
      // Test getting Paystack info from backend
      final publicKey = await _paystackService._getPublicKeyFromBackend();
      
      if (publicKey.isNotEmpty) {
        _addTestResult('✅ Backend connection successful');
        _addTestResult('Public Key: ${publicKey.substring(0, 20)}...');
      } else {
        _addTestResult('❌ Backend connection failed - no public key received');
      }
    } catch (e) {
      _addTestResult('❌ Backend connection failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPaymentInitialization() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addTestResult('Testing payment initialization...');
      
      final paymentData = await _paystackService.initializePayment(
        amount: 100.0,
        currency: 'KES',
        email: 'test@example.com',
        bookingId: 'test_booking_123',
        companyId: 11,
        userId: 'test_user_456',
        description: 'Test payment initialization',
      );
      
      _addTestResult('✅ Payment initialization successful');
      _addTestResult('Reference: ${paymentData['reference'] ?? 'N/A'}');
      _addTestResult('Amount: ${paymentData['amount'] ?? 'N/A'}');
      _addTestResult('Currency: ${paymentData['currency'] ?? 'N/A'}');
    } catch (e) {
      _addTestResult('❌ Payment initialization failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _testCardPaymentWidget() {
    _addTestResult('Opening Card Payment Widget...');
    
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: 'test_booking_123',
      companyId: 11,
      userId: 'test_user_456',
      amount: 100.0,
      currency: 'KES',
      email: 'test@example.com',
      preferredPaymentMethod: 'card',
      onSuccess: (response) {
        _addTestResult('✅ Card payment successful!');
        _addTestResult('Reference: ${response.reference}');
        _addTestResult('Status: ${response.status}');
      },
      onError: (error) {
        _addTestResult('❌ Card payment failed: $error');
      },
      onCancelled: () {
        _addTestResult('⚠️ Card payment cancelled by user');
      },
    );
  }

  void _testMpesaPaymentWidget() {
    _addTestResult('Opening M-Pesa Payment Widget...');
    
    ExistingPaymentPageIntegration.showPaystackPayment(
      context: context,
      bookingId: 'test_booking_456',
      companyId: 11,
      userId: 'test_user_456',
      amount: 100.0,
      currency: 'KES',
      email: 'test@example.com',
      preferredPaymentMethod: 'mpesa',
      onSuccess: (response) {
        _addTestResult('✅ M-Pesa payment successful!');
        _addTestResult('Reference: ${response.reference}');
        _addTestResult('Status: ${response.status}');
      },
      onError: (error) {
        _addTestResult('❌ M-Pesa payment failed: $error');
      },
      onCancelled: () {
        _addTestResult('⚠️ M-Pesa payment cancelled by user');
      },
    );
  }
}

/// Test configuration
class TestConfig {
  static const String backendUrl = 'http://192.168.100.2:5000';
  static const String testBookingId = 'test_booking_123';
  static const int testCompanyId = 11;
  static const String testUserId = 'test_user_456';
  static const String testEmail = 'test@example.com';
  static const double testAmount = 100.0;
  static const String testCurrency = 'KES';
}
