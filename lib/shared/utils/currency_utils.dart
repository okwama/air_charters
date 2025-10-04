import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Centralized currency utility for consistent currency handling across the app
class CurrencyUtils {
  // Default currency for the app (Kenya - KES)
  static const String defaultCurrency = 'KES';

  // Supported currencies with their locale mappings
  static const Map<String, String> currencyLocales = {
    'KES': 'en_KE', // Kenya
    'USD': 'en_US', // United States
    'NGN': 'en_NG', // Nigeria
    'GHS': 'en_GH', // Ghana
    'ZAR': 'en_ZA', // South Africa
    'EUR': 'en_EU', // Europe
    'GBP': 'en_GB', // United Kingdom
  };

  /// Format amount with currency symbol using intl library
  static String formatAmount(double amount, [String? currency]) {
    final currencyCode = currency ?? defaultCurrency;
    final locale =
        currencyLocales[currencyCode] ?? currencyLocales[defaultCurrency]!;

    try {
      final formatter = NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
      );
      return formatter.format(amount);
    } catch (e) {
      // Fallback to basic formatting if locale fails
      return '$currencyCode ${amount.toStringAsFixed(2)}';
    }
  }

  /// Format amount with currency code
  static String formatAmountWithCode(double amount, [String? currency]) {
    final currencyCode = currency ?? defaultCurrency;
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }

  /// Get currency symbol using intl
  static String getCurrencySymbol([String? currency]) {
    final currencyCode = currency ?? defaultCurrency;
    final locale =
        currencyLocales[currencyCode] ?? currencyLocales[defaultCurrency]!;

    try {
      final formatter = NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
      );
      return formatter.currencySymbol;
    } catch (e) {
      // Fallback symbols
      switch (currencyCode) {
        case 'KES':
          return 'KSh';
        case 'USD':
          return '\$';
        case 'NGN':
          return '₦';
        case 'GHS':
          return 'GH₵';
        case 'ZAR':
          return 'R';
        case 'EUR':
          return '€';
        case 'GBP':
          return '£';
        default:
          return currencyCode;
      }
    }
  }

  /// Check if currency is supported
  static bool isCurrencySupported(String currency) {
    return currencyLocales.containsKey(currency.toUpperCase());
  }

  /// Get all supported currencies
  static List<String> getSupportedCurrencies() {
    return currencyLocales.keys.toList();
  }

  /// Parse amount from string with currency symbol
  static double? parseAmount(String amountString) {
    try {
      // Remove currency symbols and parse
      final cleanAmount = amountString
          .replaceAll(RegExp(r'[^\d.,]'),
              '') // Remove non-numeric characters except . and ,
          .replaceAll(',', ''); // Remove commas

      return double.parse(cleanAmount);
    } catch (e) {
      return null;
    }
  }

  /// Get formatted amount for display in UI
  static String getDisplayAmount(double amount, [String? currency]) {
    return formatAmount(amount, currency);
  }

  /// Get compact formatted amount (e.g., 1.2K, 1.5M)
  static String getCompactAmount(double amount, [String? currency]) {
    final currencyCode = currency ?? defaultCurrency;
    final symbol = getCurrencySymbol(currencyCode);

    String formattedAmount;
    if (amount >= 1000000) {
      formattedAmount = '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      formattedAmount = '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      formattedAmount = amount.toStringAsFixed(0);
    }

    return '$symbol$formattedAmount';
  }
}

/// Currency formatter widget using intl
class CurrencyText extends StatelessWidget {
  final double amount;
  final String? currency;
  final TextStyle? style;
  final bool compact;

  const CurrencyText({
    super.key,
    required this.amount,
    this.currency,
    this.style,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = compact
        ? CurrencyUtils.getCompactAmount(amount, currency)
        : CurrencyUtils.formatAmount(amount, currency);

    return Text(
      formattedAmount,
      style: style,
    );
  }
}

/// Currency input formatter
class CurrencyInputFormatter {
  static String format(String value) {
    // Remove non-numeric characters
    final cleanValue = value.replaceAll(RegExp(r'[^\d.,]'), '');

    // Add thousands separators
    final parts = cleanValue.split('.');
    if (parts.length > 2) {
      // Invalid format
      return value;
    }

    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add commas for thousands
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    return formattedInteger + decimalPart;
  }
}
