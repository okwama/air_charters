import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'settings.dart';

void main() {
  group('Settings Functionality Tests', () {
    testWidgets('Settings screen displays current values correctly', (WidgetTester tester) async {
      // Build the settings screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the settings screen is displayed
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App Preferences'), findsOneWidget);

      // Verify that the current values are displayed (defaults)
      expect(find.text('Auto (System)'), findsOneWidget); // Default theme
      expect(find.text('English'), findsOneWidget); // Default language
      expect(find.text('US Dollar (\$)'), findsOneWidget); // Default currency
    });

    testWidgets('Theme page opens and allows selection', (WidgetTester tester) async {
      // Build the settings screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the theme setting
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Verify theme page is opened
      expect(find.text('Theme Settings'), findsOneWidget);
      expect(find.text('Choose Your Theme'), findsOneWidget);

      // Verify theme options are displayed
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Auto (System)'), findsOneWidget);
    });

    testWidgets('Language page opens and allows selection', (WidgetTester tester) async {
      // Build the settings screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the language setting
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Verify language page is opened
      expect(find.text('Language Settings'), findsOneWidget);
      expect(find.text('Choose Your Language'), findsOneWidget);

      // Verify language options are displayed
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('French'), findsOneWidget);
    });

    testWidgets('Currency page opens and allows selection', (WidgetTester tester) async {
      // Build the settings screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the currency setting
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      // Verify currency page is opened
      expect(find.text('Currency Settings'), findsOneWidget);
      expect(find.text('Choose Your Currency'), findsOneWidget);

      // Verify currency options are displayed
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('Euro'), findsOneWidget);
      expect(find.text('British Pound'), findsOneWidget);
    });
  });
}

