import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/error/network_error_handler.dart';
import '../../../config/env/app_config.dart';

class InAppCheckoutScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String currency;
  final String email;
  final int companyId;
  final String preferredPaymentMethod;

  const InAppCheckoutScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.email,
    required this.companyId,
    required this.preferredPaymentMethod,
  });

  @override
  State<InAppCheckoutScreen> createState() => _InAppCheckoutScreenState();
}

class _InAppCheckoutScreenState extends State<InAppCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _authorizationUrl;
  String? _reference;
  int _statusCheckCount = 0;
  static const int _maxStatusChecks =
      AppConfig.maxPaymentStatusChecks; // Maximum checks from config
  static const int _statusCheckInterval =
      AppConfig.paymentStatusCheckIntervalSeconds *
          1000; // Check interval from config
  bool _hasPaymentCompleted = false; // Prevent multiple completion calls
  Timer? _urlChangeTimer; // For debouncing URL changes
  Timer? _statusCheckTimer; // For payment status checking
  double _paymentProgress = 0.0; // Track payment progress
  bool _isOffline = false; // Track network connectivity
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _initializeConnectivityMonitoring();

    // Initialize payment after the first frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  @override
  void dispose() {
    _urlChangeTimer?.cancel();
    _connectivitySubscription?.cancel();
    // Stop any ongoing status checks when screen is disposed
    _stopStatusChecking();
    super.dispose();
  }

  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        setState(() {
          _isOffline = result == ConnectivityResult.none;
        });

        if (_isOffline) {
          _showOfflineMessage();
        } else {
          _hideOfflineMessage();
        }
      },
    );
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
            setState(() {
              _paymentProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _paymentProgress = 0.0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _paymentProgress = 1.0;
            });

            // Debounced URL change handling
            _handleUrlChange(url);
          },
          onWebResourceError: (WebResourceError error) {
            _handleWebViewError(error);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation but log for security
            AppLogger().log(
              'Navigation request: ${request.url}',
              level: LogLevel.debug,
              category: LogCategory.payment,
            );
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  void _handleWebViewError(WebResourceError error) {
    String errorMessage;

    switch (error.errorType) {
      case WebResourceErrorType.hostLookup:
        errorMessage =
            'Network error: Unable to reach payment server. Please check your internet connection.';
        break;
      case WebResourceErrorType.timeout:
        errorMessage =
            'Connection timeout: Payment server is taking too long to respond. Please try again.';
        break;
      case WebResourceErrorType.unknown:
        errorMessage = 'Unknown error: ${error.description}';
        break;
      default:
        errorMessage = 'Failed to load payment page: ${error.description}';
    }

    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
      _paymentProgress = 0.0;
    });
  }

  void _showOfflineMessage() {
    if (mounted && !_hasPaymentCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 8),
              Text('No internet connection. Please check your network.'),
            ],
          ),
          backgroundColor: Colors.orange[600],
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _retryPayment();
            },
          ),
        ),
      );
    }
  }

  void _hideOfflineMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  void _retryPayment() {
    // Reset payment state for retry
    _hasPaymentCompleted = false;
    _isProcessing = false;
    _statusCheckCount = 0;
    _stopStatusChecking(); // Stop any ongoing status checks

    if (_authorizationUrl != null) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      _controller.loadRequest(Uri.parse(_authorizationUrl!));
    } else {
      // If no authorization URL, reinitialize payment
      _initializePayment();
    }
  }

  Future<void> _initializePayment() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bookingProvider = context.read<BookingProvider>();
      final authProvider = context.read<AuthProvider>();

      AppLogger().log(
        'Initializing payment',
        level: LogLevel.info,
        category: LogCategory.payment,
        data: {
          'amount': widget.amount,
          'currency': widget.currency,
          'bookingId': widget.bookingId,
          'userId': authProvider.currentUser?.id,
          'companyId': widget.companyId,
          'email': widget.email,
        },
      );

      // Create Paystack payment intent with timeout
      final paymentData = await Future.any([
        bookingProvider.createPaystackPaymentIntent(
          amount: widget.amount,
          bookingId: widget.bookingId,
          userId: authProvider.currentUser?.id ?? '',
          companyId: widget.companyId,
          email: widget.email,
          currency: widget.currency,
          description: 'Payment for booking ${widget.bookingId}',
          preferredPaymentMethod: widget.preferredPaymentMethod,
        ),
        Future.delayed(
          Duration(seconds: AppConfig.paymentInitializationTimeoutSeconds),
          () => throw TimeoutException('Payment initialization timeout',
              Duration(seconds: AppConfig.paymentInitializationTimeoutSeconds)),
        ),
      ]);

      AppLogger().log(
        'Payment data received',
        level: LogLevel.info,
        category: LogCategory.payment,
        data: {'paymentData': paymentData},
      );

      if (paymentData != null &&
          paymentData['nextAction']?['redirect_to_url']?['url'] != null) {
        _authorizationUrl = paymentData['nextAction']['redirect_to_url']['url'];
        _reference = paymentData['id'];

        // Load the Paystack checkout page in WebView
        await _controller.loadRequest(Uri.parse(_authorizationUrl!));
      } else {
        setState(() {
          _errorMessage =
              'Failed to initialize payment - no authorization URL received';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        final errorResult = NetworkErrorResult.fromException(e);
        _errorMessage = errorResult.message;
        AppLogger().log(
          'Payment initialization failed',
          level: LogLevel.error,
          category: LogCategory.payment,
          error: e,
        );
        _isLoading = false;
      });
    }
  }

  void _handleUrlChange(String url) {
    AppLogger().log(
      'URL changed',
      level: LogLevel.debug,
      category: LogCategory.payment,
      data: {'url': url},
    );

    // Cancel any existing timer
    _urlChangeTimer?.cancel();

    // Debounce URL changes to prevent rapid-fire processing
    _urlChangeTimer = Timer(Duration(milliseconds: 500), () {
      _processUrlChange(url);
    });
  }

  void _processUrlChange(String url) {
    AppLogger().log(
      'Processing URL change',
      level: LogLevel.debug,
      category: LogCategory.payment,
      data: {
        'url': url,
        '_hasPaymentCompleted': _hasPaymentCompleted,
        '_isProcessing': _isProcessing,
      },
    );

    // Prevent processing if payment already completed or currently processing
    if (_hasPaymentCompleted || _isProcessing) {
      AppLogger().log(
        'Payment already completed or processing, ignoring URL change',
        level: LogLevel.debug,
        category: LogCategory.payment,
      );
      return;
    }

    // Check for success patterns
    if (_isSuccessUrl(url)) {
      AppLogger().log(
        'Success URL detected',
        level: LogLevel.info,
        category: LogCategory.payment,
        data: {'url': url},
      );

      // Mark as processing to prevent multiple verifications
      _isProcessing = true;

      // Verify payment and close WebView
      _verifyPayment();
    } else if (_isFailureUrl(url)) {
      AppLogger().log(
        'Failure URL detected',
        level: LogLevel.warning,
        category: LogCategory.payment,
        data: {'url': url},
      );
      _showPaymentFailure('Payment was cancelled or failed');
    } else if (_isPaystackCheckoutUrl(url)) {
      AppLogger().log(
        'Paystack checkout URL detected',
        level: LogLevel.info,
        category: LogCategory.payment,
        data: {'url': url},
      );
      // Don't automatically start polling - let user complete payment naturally
      // Only start polling if we've been on this page for a while
      _scheduleDelayedStatusCheck();
    }
  }

  bool _isSuccessUrl(String url) {
    // Check against configured patterns
    final isSuccess = AppConfig.paymentSuccessUrlPatterns
        .any((pattern) => url.toLowerCase().contains(pattern));

    // Also check if it's the current backend verification URL
    final isBackendVerification =
        AppConfig.isCurrentBackendVerificationUrl(url);

    final finalResult = isSuccess || isBackendVerification;

    AppLogger().log(
      'Checking success URL',
      level: LogLevel.debug,
      category: LogCategory.payment,
      data: {
        'url': url,
        'isSuccess': finalResult,
        'isBackendVerification': isBackendVerification,
        'matchedPatterns': AppConfig.paymentSuccessUrlPatterns
            .where((pattern) => url.toLowerCase().contains(pattern))
            .toList(),
        'currentBackendUrl': AppConfig.currentBackendVerificationUrl,
        'currentPaystackBackendUrl':
            AppConfig.currentBackendPaystackVerificationUrl,
        'allSuccessPatterns': AppConfig.paymentSuccessUrlPatterns,
      },
    );

    return finalResult;
  }

  bool _isFailureUrl(String url) {
    return AppConfig.paymentFailureUrlPatterns
        .any((pattern) => url.toLowerCase().contains(pattern));
  }

  bool _isPaystackCheckoutUrl(String url) {
    return AppConfig.paystackCheckoutUrlPatterns
        .any((pattern) => url.toLowerCase().contains(pattern));
  }

  void _scheduleDelayedStatusCheck() {
    // Only start status checking if we've been on Paystack for more than 30 seconds
    Timer(Duration(seconds: 30), () {
      if (!_hasPaymentCompleted && !_isProcessing && _statusCheckCount == 0) {
        AppLogger().log(
          'Starting delayed status check after 30 seconds',
          level: LogLevel.info,
          category: LogCategory.payment,
        );
        _checkPaymentStatus();
      }
    });
  }

  void _stopStatusChecking() {
    _statusCheckTimer?.cancel();
    _statusCheckCount = 0;
    _isProcessing = false;
  }

  Future<void> _checkPaymentStatus() async {
    if (_reference == null || _isProcessing || _hasPaymentCompleted) return;

    // Check if we've exceeded the maximum number of checks
    if (_statusCheckCount >= _maxStatusChecks) {
      AppLogger().log(
        'Maximum payment status checks reached, stopping',
        level: LogLevel.warning,
        category: LogCategory.payment,
      );
      _stopStatusChecking();
      _showPaymentFailure(
          'Payment verification timeout. Please check your booking status manually.');
      return;
    }

    _statusCheckCount++;
    AppLogger().log(
      'Payment status check',
      level: LogLevel.debug,
      category: LogCategory.payment,
      data: {'checkCount': _statusCheckCount},
    );

    try {
      // Wait a bit for the payment to process
      await Future.delayed(Duration(milliseconds: _statusCheckInterval));

      // Check if we're still processing (prevent multiple concurrent checks)
      if (_isProcessing) return;

      final bookingProvider = context.read<BookingProvider>();

      // Check payment status with backend
      final result = await bookingProvider.verifyPaystackPayment(
        reference: _reference!,
        bookingId: widget.bookingId,
      );

      AppLogger().log(
        'Payment status check result',
        level: LogLevel.debug,
        category: LogCategory.payment,
        data: {'result': result},
      );

      if (result != null && result['success'] == true) {
        final status = result['data']['status'];

        if (status == 'succeeded' || status == 'success') {
          // Payment successful - STOP POLLING
          _hasPaymentCompleted = true;

          AppLogger().log(
            'Payment successful detected in status check',
            level: LogLevel.info,
            category: LogCategory.payment,
            data: {'status': status, 'url': _controller.currentUrl()},
          );

          _showPaymentSuccess();
          return; // Exit immediately
        } else if (status == 'abandoned') {
          // Payment was abandoned - but don't stop polling immediately
          // Give user a chance to retry the payment
          AppLogger().log(
            'Payment abandoned, but allowing retry',
            level: LogLevel.warning,
            category: LogCategory.payment,
          );

          // Only stop polling after multiple abandoned statuses
          if (_statusCheckCount >= _maxStatusChecks) {
            _hasPaymentCompleted = true;
            _showPaymentFailure('Payment was not completed. Please try again.');
            return;
          }

          // Continue checking in case user retries
          if (!_isProcessing && _statusCheckCount < _maxStatusChecks) {
            _checkPaymentStatus();
          }
        } else if (status == 'pending') {
          // Payment still processing, check again in a few seconds
          if (!_isProcessing && _statusCheckCount < _maxStatusChecks) {
            _checkPaymentStatus();
          }
        } else {
          // Payment failed - STOP POLLING
          _hasPaymentCompleted = true;
          final failureReason = result['data']['metadata']?['failureReason'] ??
              result['data']['metadata']?['gateway_response'] ??
              'Payment failed';
          _showPaymentFailure(failureReason);
          return; // Exit immediately
        }
      } else {
        // If verification fails, try again in a few seconds (but limit retries)
        if (!_isProcessing && _statusCheckCount < _maxStatusChecks) {
          _checkPaymentStatus();
        } else {
          _showPaymentFailure(
              'Payment verification failed after multiple attempts');
        }
      }
    } catch (e) {
      // Log error for debugging but don't show to user
      // Payment status check will retry automatically
      // If there's an error, try again in a few seconds (but limit retries)
      if (!_isProcessing && _statusCheckCount < _maxStatusChecks) {
        _checkPaymentStatus();
      } else {
        final errorResult = NetworkErrorResult.fromException(e);
        _showPaymentFailure(errorResult.message);
        AppLogger().log(
          'Payment verification failed',
          level: LogLevel.error,
          category: LogCategory.payment,
          error: e,
        );
      }
    }
  }

  Future<void> _verifyPayment() async {
    if (_reference == null || _hasPaymentCompleted) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final bookingProvider = context.read<BookingProvider>();

      // Verify payment with backend
      final result = await bookingProvider.verifyPaystackPayment(
        reference: _reference!,
        bookingId: widget.bookingId,
      );

      AppLogger().log(
        'Payment verification result',
        level: LogLevel.info,
        category: LogCategory.payment,
        data: {'result': result},
      );

      if (result != null && result['success'] == true) {
        final status = result['data']['status'];

        if (status == 'succeeded' || status == 'success') {
          // Payment successful
          _hasPaymentCompleted = true;

          // Add a small delay to ensure WebView processes the success URL
          await Future.delayed(Duration(milliseconds: 500));

          _showPaymentSuccess();
        } else if (status == 'abandoned') {
          // Payment was abandoned (user didn't complete)
          _hasPaymentCompleted = true;
          _showPaymentFailure('Payment was not completed. Please try again.');
        } else {
          // Payment failed
          _hasPaymentCompleted = true;
          final failureReason = result['data']['metadata']?['failureReason'] ??
              result['data']['metadata']?['gateway_response'] ??
              'Payment failed';
          _showPaymentFailure(failureReason);
        }
      } else {
        _showPaymentFailure('Payment verification failed');
      }
    } catch (e) {
      // Log error for debugging but don't show to user
      // Payment verification will be handled by the retry mechanism
      final errorResult = NetworkErrorResult.fromException(e);
      _showPaymentFailure(errorResult.message);
      AppLogger().log(
        'Payment verification failed',
        level: LogLevel.error,
        category: LogCategory.payment,
        error: e,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showPaymentSuccess() {
    if (!mounted) return;

    // Update progress to show completion
    setState(() {
      _paymentProgress = 1.0;
    });

    // Show success message with better styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Successful!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Redirecting to booking details...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );

    // Close WebView and navigate to booking confirmation after user sees success message
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(true); // Return success to previous screen
      }
    });
  }

  void _showPaymentFailure(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Payment Failed',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reason,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please try again or contact support if the issue persists.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Retry button for abandoned payments
          if (reason.contains('not completed') || reason.contains('abandoned'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _retryPayment();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry Payment',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context)
                  .pop(false); // Return to previous screen with failure
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Stack(
        children: [
          // WebView
          if (_authorizationUrl != null) WebViewWidget(controller: _controller),

          // Offline indicator
          if (_isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange[600],
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No internet connection',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _retryPayment,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating action button to check payment status
          if (_authorizationUrl != null &&
              !_isLoading &&
              !_isProcessing &&
              _errorMessage == null &&
              !_hasPaymentCompleted)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _hasPaymentCompleted ? null : _verifyPayment,
                backgroundColor: _hasPaymentCompleted
                    ? Colors.grey[400]
                    : AppTheme.primaryColor,
                tooltip: _hasPaymentCompleted
                    ? 'Payment Completed'
                    : 'Check Payment Status',
                child: Icon(
                  _hasPaymentCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: Colors.white,
                ),
              ),
            ),

          // Loading overlay
          if (_isLoading || _isProcessing)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Progress indicator
                    if (_paymentProgress > 0 && _paymentProgress < 1) ...[
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: _paymentProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_paymentProgress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Circular progress indicator
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isProcessing
                          ? 'Verifying payment...'
                          : 'Loading payment page...',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                    // Additional status text
                    if (_isProcessing) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while we confirm your payment',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Error overlay
          if (_errorMessage != null)
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Payment Error',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                              _initializePayment();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed:
                                _hasPaymentCompleted ? null : _verifyPayment,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _hasPaymentCompleted
                                  ? Colors.grey[400]
                                  : AppTheme.primaryColor,
                              side: BorderSide(
                                  color: _hasPaymentCompleted
                                      ? Colors.grey[400]!
                                      : AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _hasPaymentCompleted
                                  ? 'Payment Completed'
                                  : 'Check Status',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
