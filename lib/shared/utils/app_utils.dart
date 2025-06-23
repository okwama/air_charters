import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppUtils {
  // Safe setState function
  static void safeSetState(VoidCallback fn) {
    try {
      fn();
    } catch (e) {
      debugPrint('Error in safeSetState: $e');
    }
  }

  // Show success snackbar
  static void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  // Show error snackbar
  static void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  // Show info snackbar
  static void showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue[600],
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Format currency
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Check if device is tablet
  static bool isTablet(BuildContext context) {
    final size = getScreenSize(context);
    return size.width > 600;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final size = getScreenSize(context);
    if (isTablet(context)) {
      return const EdgeInsets.all(32);
    } else {
      return EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: 16,
      );
    }
  }

  // Debounce function
  static Function debounce(Function func, Duration wait) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(wait, () => func());
    };
  }

  // Throttle function
  static Function throttle(Function func, Duration wait) {
    DateTime? lastRun;
    return () {
      if (lastRun == null || DateTime.now().difference(lastRun!) >= wait) {
        func();
        lastRun = DateTime.now();
      }
    };
  }
}
