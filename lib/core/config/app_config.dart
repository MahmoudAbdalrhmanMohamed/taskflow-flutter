import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  /// Default API base URL points to live cloud API
  static String get defaultBaseUrl {
    return productionBaseUrl;
  }

  /// Cloud API endpoint for production
  static const String productionBaseUrl = 'https://taskflow-nestjs-api.vercel.app/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
