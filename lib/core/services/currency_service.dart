import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env/app_config.dart';
import '../error/network_error_handler.dart';
import '../logging/app_logger.dart';

class CurrencyService {
  static String get _baseUrl => '${AppConfig.baseUrl}/api/payments';

  // Cache for exchange rates
  static final Map<String, _CachedRate> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get exchange rate between two currencies
  static Future<double> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    final cacheKey = '${from}_$to';
    final cached = _cache[cacheKey];

    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _cacheDuration) {
      return cached.rate;
    }

    try {
      // Try to get rate from backend first
      final response = await http.get(
        Uri.parse('$_baseUrl/exchange-rate?from=$from&to=$to'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rate']?.toDouble() ?? 1.0;

        // Cache the result
        _cache[cacheKey] = _CachedRate(rate, DateTime.now());
        return rate;
      }
    } catch (e) {
      // Log technical error for debugging but don't show to user
      AppLogger().log(
        'Failed to fetch exchange rate from backend',
        level: LogLevel.error,
        category: LogCategory.network,
        error: e,
      );

      // Convert to user-friendly error for logging purposes
      final errorResult = NetworkErrorResult.fromException(e);
      AppLogger().log(
        'Using fallback exchange rate due to: ${errorResult.message}',
        level: LogLevel.warning,
        category: LogCategory.network,
      );
    }

    // Fallback to hardcoded rates
    final fallbackRate = _getFallbackRate(from, to);
    _cache[cacheKey] = _CachedRate(fallbackRate, DateTime.now());
    return fallbackRate;
  }

  /// Convert amount from one currency to another
  static Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    final rate = await getExchangeRate(from, to);
    return amount * rate;
  }

  /// Get USD to KES rate (most common conversion)
  static Future<double> getUSDToKESRate() async {
    return await getExchangeRate('USD', 'KES');
  }

  /// Get KES to USD rate
  static Future<double> getKESToUSDRate() async {
    return await getExchangeRate('KES', 'USD');
  }

  /// Format price with currency symbol
  static String formatPrice(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'KES':
        return 'KSh ${amount.toStringAsFixed(0)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      default:
        return '$amount $currency';
    }
  }

  /// Format price with currency symbol and conversion
  static Future<String> formatPriceWithConversion({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return formatPrice(amount, fromCurrency);
    }

    final convertedAmount = await convertCurrency(
      amount: amount,
      from: fromCurrency,
      to: toCurrency,
    );

    return formatPrice(convertedAmount, toCurrency);
  }

  /// Get price in both USD and KES
  static Future<Map<String, String>> getDualCurrencyPrice({
    required double usdAmount,
  }) async {
    final kesAmount = await convertCurrency(
      amount: usdAmount,
      from: 'USD',
      to: 'KES',
    );

    return {
      'USD': formatPrice(usdAmount, 'USD'),
      'KES': formatPrice(kesAmount, 'KES'),
    };
  }

  /// Clear cache (useful for testing or manual refresh)
  static void clearCache() {
    _cache.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'size': _cache.length,
      'keys': _cache.keys.toList(),
    };
  }

  /// Fallback rates when API is unavailable
  static double _getFallbackRate(String from, String to) {
    final fallbackRates = {
      'USD_KES': 129.0, // 1 USD = 129 KES
      'KES_USD': 0.0077, // 1 KES = 0.0077 USD
      'USD_EUR': 0.92, // 1 USD = 0.92 EUR
      'EUR_USD': 1.09, // 1 EUR = 1.09 USD
      'USD_GBP': 0.79, // 1 USD = 0.79 GBP
      'GBP_USD': 1.27, // 1 GBP = 1.27 USD
    };

    final key = '${from}_$to';
    return fallbackRates[key] ?? 1.0;
  }
}

class _CachedRate {
  final double rate;
  final DateTime timestamp;

  _CachedRate(this.rate, this.timestamp);
}
