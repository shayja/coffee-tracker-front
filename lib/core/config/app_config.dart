// lib/core/config/app_config.dart
import 'dart:io';

import 'package:coffee_tracker/core/config/environment.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Compile-time constants
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('BASE_URL');
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    if (kReleaseMode) {
      // Production URL should be set via --dart-define=BASE_URL=...
      // Fallback if not provided in release mode (though ideally should be provided)
      return 'https://coffee-tracker-backend.fly.dev/api/v1';
    }

    // Development fallbacks
    // specific IP for physical devices on the same network
    // 10.0.0.4 is the current machine IP detected via ifconfig
    if (Platform.isAndroid) {
      return 'http://10.0.0.4:3000/api/v1';
    } else if (Platform.isIOS) {
      return 'http://10.0.0.4:3000/api/v1';
    }

    // Default for other platforms (web, desktop, etc.)
    return 'http://localhost:3000/api/v1';
  }

  static const Environment environment =
      String.fromEnvironment('ENVIRONMENT') == 'production'
      ? Environment.production
      : Environment.development;
}
