import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../config/env/app_config.dart';
import 'dart:developer' as developer;

class Telemetry {
  static final Telemetry _instance = Telemetry._internal();
  factory Telemetry() => _instance;
  Telemetry._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (!AppConfig.enableSentry || AppConfig.sentryDsn.isEmpty) {
      if (kDebugMode) developer.log('Sentry disabled or DSN missing', name: 'telemetry');
      _initialized = false;
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.sentryDsn;
        options.environment = AppConfig.isDevelopment ? 'development' : 'production';
        options.tracesSampleRate = 0.1;
      },
      appRunner: () {},
    );

    _initialized = true;
    developer.log('Sentry initialized', name: 'telemetry');
  }

  Future<void> captureException(Object error, {StackTrace? stackTrace, Map<String, dynamic>? tags}) async {
    if (!_initialized) return;
    await Sentry.captureException(error, stackTrace: stackTrace, hint: tags);
  }

  Future<void> captureMessage(String message, {Map<String, dynamic>? tags}) async {
    if (!_initialized) return;
    await Sentry.captureMessage(message);
  }
}
