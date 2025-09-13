import 'package:flutter/material.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey) ?? 'system';
      _themeMode = _stringToThemeMode(themeString);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  Future<void> setThemeMode(String themeString) async {
    final newThemeMode = _stringToThemeMode(themeString);
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      await _saveThemeMode(themeString);
      notifyListeners();
    }
  }

  Future<void> _saveThemeMode(String themeString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'auto':
      default:
        return ThemeMode.system;
    }
  }

  // Light theme with flex_seed_scheme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: SeedColorScheme.fromSeeds(
        brightness: Brightness.light,
        primaryKey: const Color(0xFF1976D2), // Blue
        secondary: const Color(0xFF26A69A), // Teal
        tertiary: const Color(0xFF7B1FA2), // Purple
      ),
      fontFamily: 'Outfit',
      // Ensure proper text colors in light mode
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black87),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  // Dark theme with flex_seed_scheme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: SeedColorScheme.fromSeeds(
        brightness: Brightness.dark,
        primaryKey: const Color(0xFF90CAF9), // Light Blue
        secondary: const Color(0xFF80CBC4), // Light Teal
        tertiary: const Color(0xFFCE93D8), // Light Purple
      ),
      fontFamily: 'Outfit',
      // Ensure proper text colors in dark mode
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Dark mode specific colors
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.white24,
    );
  }
}
