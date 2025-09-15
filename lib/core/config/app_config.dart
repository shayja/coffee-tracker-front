// lib/core/config/app_config.dart
import 'package:coffee_tracker/core/config/environment.dart';

class AppConfig {
  // Compile-time constants
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.0.3:3000/api/v1', // Dev fallback
    //defaultValue: 'http://localhost:3000/api/v1', // Dev fallback
  );

  static const Environment environment =
      String.fromEnvironment('ENVIRONMENT') == 'production'
      ? Environment.production
      : Environment.development;
}
