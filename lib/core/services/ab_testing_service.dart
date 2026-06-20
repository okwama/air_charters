import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for A/B testing different prompt variations and features
class ABTestingService {
  static const String _testAssignmentsKey = 'ab_test_assignments';
  static const String _testResultsKey = 'ab_test_results';
  static const String _testConfigKey = 'ab_test_config';

  /// Assign user to a test variant
  static Future<String> assignToTest(String testName, List<String> variants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing assignments
      final assignmentsJson = prefs.getString(_testAssignmentsKey);
      Map<String, String> assignments = {};
      
      if (assignmentsJson != null) {
        assignments = Map<String, String>.from(jsonDecode(assignmentsJson));
      }
      
      // Check if already assigned
      if (assignments.containsKey(testName)) {
        return assignments[testName]!;
      }
      
      // Assign to variant using weighted random selection
      final variant = _selectVariant(variants);
      assignments[testName] = variant;
      
      await prefs.setString(_testAssignmentsKey, jsonEncode(assignments));
      
      if (kDebugMode) {
        print('ABTestingService: Assigned to test $testName, variant: $variant');
      }
      
      return variant;
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error assigning to test: $e');
      }
      // Return first variant as fallback
      return variants.isNotEmpty ? variants.first : 'control';
    }
  }

  /// Get current test assignment
  static Future<String?> getTestAssignment(String testName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignmentsJson = prefs.getString(_testAssignmentsKey);
      
      if (assignmentsJson != null) {
        final assignments = Map<String, String>.from(jsonDecode(assignmentsJson));
        return assignments[testName];
      }
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error getting test assignment: $e');
      }
    }
    
    return null;
  }

  /// Record test result
  static Future<void> recordTestResult({
    required String testName,
    required String variant,
    required String eventType,
    required String eventName,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing results
      final resultsJson = prefs.getString(_testResultsKey);
      Map<String, dynamic> results = {};
      
      if (resultsJson != null) {
        results = Map<String, dynamic>.from(jsonDecode(resultsJson));
      }
      
      // Initialize test results if not exists
      if (!results.containsKey(testName)) {
        results[testName] = {};
      }
      
      if (!results[testName].containsKey(variant)) {
        results[testName][variant] = {};
      }
      
      if (!results[testName][variant].containsKey(eventType)) {
        results[testName][variant][eventType] = [];
      }
      
      // Add event
      results[testName][variant][eventType].add({
        'eventName': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'data': eventData ?? {},
      });
      
      await prefs.setString(_testResultsKey, jsonEncode(results));
      
      if (kDebugMode) {
        print('ABTestingService: Recorded result for $testName/$variant: $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error recording test result: $e');
      }
    }
  }

  /// Get test results
  static Future<ABTestResults> getTestResults(String testName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getString(_testResultsKey);
      
      if (resultsJson != null) {
        final results = Map<String, dynamic>.from(jsonDecode(resultsJson));
        final testResults = results[testName];
        
        if (testResults != null) {
          return ABTestResults.fromJson(testResults);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error getting test results: $e');
      }
    }
    
    return ABTestResults.empty();
  }

  /// Configure A/B test
  static Future<void> configureTest({
    required String testName,
    required Map<String, ABTestVariant> variants,
    String? description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing config
      final configJson = prefs.getString(_testConfigKey);
      Map<String, dynamic> config = {};
      
      if (configJson != null) {
        config = Map<String, dynamic>.from(jsonDecode(configJson));
      }
      
      // Add test configuration
      config[testName] = {
        'description': description,
        'variants': variants.map((key, value) => MapEntry(key, value.toJson())),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_testConfigKey, jsonEncode(config));
      
      if (kDebugMode) {
        print('ABTestingService: Configured test $testName with ${variants.length} variants');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error configuring test: $e');
      }
    }
  }

  /// Get test configuration
  static Future<ABTestConfig?> getTestConfig(String testName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_testConfigKey);
      
      if (configJson != null) {
        final config = Map<String, dynamic>.from(jsonDecode(configJson));
        final testConfig = config[testName];
        
        if (testConfig != null) {
          return ABTestConfig.fromJson(testConfig);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error getting test config: $e');
      }
    }
    
    return null;
  }

  /// Clear test data
  static Future<void> clearTestData(String testName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear assignments
      final assignmentsJson = prefs.getString(_testAssignmentsKey);
      if (assignmentsJson != null) {
        final assignments = Map<String, String>.from(jsonDecode(assignmentsJson));
        assignments.remove(testName);
        await prefs.setString(_testAssignmentsKey, jsonEncode(assignments));
      }
      
      // Clear results
      final resultsJson = prefs.getString(_testResultsKey);
      if (resultsJson != null) {
        final results = Map<String, dynamic>.from(jsonDecode(resultsJson));
        results.remove(testName);
        await prefs.setString(_testResultsKey, jsonEncode(results));
      }
      
      // Clear config
      final configJson = prefs.getString(_testConfigKey);
      if (configJson != null) {
        final config = Map<String, dynamic>.from(jsonDecode(configJson));
        config.remove(testName);
        await prefs.setString(_testConfigKey, jsonEncode(config));
      }
      
      if (kDebugMode) {
        print('ABTestingService: Cleared test data for $testName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ABTestingService: Error clearing test data: $e');
      }
    }
  }

  /// Select variant using weighted random selection
  static String _selectVariant(List<String> variants) {
    if (variants.isEmpty) return 'control';
    if (variants.length == 1) return variants.first;
    
    // For now, use equal distribution
    // In production, you might want to implement weighted selection
    final random = Random();
    return variants[random.nextInt(variants.length)];
  }
}

/// A/B test variant configuration
class ABTestVariant {
  final String name;
  final String description;
  final Map<String, dynamic> config;
  final double weight;

  const ABTestVariant({
    required this.name,
    required this.description,
    required this.config,
    this.weight = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'config': config,
      'weight': weight,
    };
  }

  factory ABTestVariant.fromJson(Map<String, dynamic> json) {
    return ABTestVariant(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      weight: (json['weight'] ?? 1.0).toDouble(),
    );
  }
}

/// A/B test configuration
class ABTestConfig {
  final String description;
  final Map<String, ABTestVariant> variants;
  final DateTime createdAt;

  const ABTestConfig({
    required this.description,
    required this.variants,
    required this.createdAt,
  });

  factory ABTestConfig.fromJson(Map<String, dynamic> json) {
    final variantsJson = json['variants'] as Map<String, dynamic>;
    final variants = variantsJson.map((key, value) => 
      MapEntry(key, ABTestVariant.fromJson(value as Map<String, dynamic>)));
    
    return ABTestConfig(
      description: json['description'] ?? '',
      variants: variants,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// A/B test results
class ABTestResults {
  final Map<String, Map<String, List<Map<String, dynamic>>>> results;

  const ABTestResults({
    required this.results,
  });

  factory ABTestResults.empty() {
    return const ABTestResults(results: {});
  }

  factory ABTestResults.fromJson(Map<String, dynamic> json) {
    final results = <String, Map<String, List<Map<String, dynamic>>>>{};
    
    for (final entry in json.entries) {
      final variant = entry.key;
      final variantData = entry.value as Map<String, dynamic>;
      
      results[variant] = {};
      for (final eventType in variantData.keys) {
        final events = (variantData[eventType] as List).cast<Map<String, dynamic>>();
        results[variant]![eventType] = events;
      }
    }
    
    return ABTestResults(results: results);
  }

  /// Get conversion rate for a variant
  double getConversionRate(String variant, String conversionEvent) {
    final variantResults = results[variant];
    if (variantResults == null) return 0.0;
    
    final conversionEvents = variantResults[conversionEvent] ?? [];
    final totalEvents = variantResults.values.expand((e) => e).length;
    
    if (totalEvents == 0) return 0.0;
    return conversionEvents.length / totalEvents;
  }

  /// Get total events for a variant
  int getTotalEvents(String variant) {
    final variantResults = results[variant];
    if (variantResults == null) return 0;
    
    return variantResults.values.expand((e) => e).length;
  }

  /// Get winning variant based on conversion rate
  String? getWinningVariant(String conversionEvent) {
    if (results.isEmpty) return null;
    
    String? winningVariant;
    double highestConversionRate = 0.0;
    
    for (final variant in results.keys) {
      final conversionRate = getConversionRate(variant, conversionEvent);
      if (conversionRate > highestConversionRate) {
        highestConversionRate = conversionRate;
        winningVariant = variant;
      }
    }
    
    return winningVariant;
  }
}



