import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Black and White Theme
  static const Color primaryColor = Color(0xFFFF6700); // Burnt Orange
  static const Color secondaryColor = Color(0xFF1A1A1A); // Dark Gray
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color inputFillColor = Color(0xFFF5F5F5); // Very Light Gray for inputs
  static const Color errorColor = Color(0xFFE53E3E); // Red
  static const Color successColor = Color(0xFF38A169); // Green
  static const Color textPrimaryColor = Color(0xFF000000); // Black
  static const Color textSecondaryColor = Color(0xFF666666); // Gray
  static const Color hintTextColor = Color(0xFF888888); // Lighter Gray for hints
  static const Color borderColor = Color(0xFFE5E5E5); // Light Gray
  static const Color dividerColor = Color(0xFFE5E5E5); // Light Gray for dividers

  // Text Styles - All using Inter for consistency
  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -1.0,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
        height: 1.4,
      );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide.none,
        ),
        elevation: 0,
        textStyle: bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: primaryColor, width: 1),
        ),
        elevation: 0,
        textStyle: bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      );

  // Input Decoration
  static InputDecoration get inputDecoration => InputDecoration(
        fillColor: backgroundColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: bodyMedium.copyWith(color: textSecondaryColor),
      );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide.none,
            ),
            elevation: 0,
            textStyle: bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: backgroundColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: errorColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textTheme: TextTheme(
          displayLarge: heading1,
          displayMedium: heading2,
          displaySmall: heading3,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelSmall: caption,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: heading3.copyWith(color: textPrimaryColor),
          iconTheme: const IconThemeData(color: textPrimaryColor),
        ),
      );

  // Dark theme - keeping monochrome aesthetic with inverted colors
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFFFFF), // White as primary in dark mode
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000), // Black background
        primaryColor: const Color(0xFFFFFFFF), // White as primary
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide.none,
            ),
            elevation: 0,
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF1A1A1A), // Dark gray for inputs
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: errorColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textTheme: TextTheme(
          displayLarge: heading1.copyWith(color: Colors.white),
          displayMedium: heading2.copyWith(color: Colors.white),
          displaySmall: heading3.copyWith(color: Colors.white),
          bodyLarge: bodyLarge.copyWith(color: Colors.white),
          bodyMedium: bodyMedium.copyWith(color: Colors.white),
          bodySmall: bodySmall.copyWith(color: Color(0xFFB3B3B3)),
          labelSmall: caption.copyWith(color: Color(0xFFB3B3B3)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF000000),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: heading3.copyWith(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardColor: const Color(0xFF1A1A1A),
        dividerColor: const Color(0xFF333333),
      );
}
