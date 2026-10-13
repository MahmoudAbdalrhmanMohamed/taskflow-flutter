import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  /// Default API base URL depending on platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    // Android emulator loops 10.0.2.2 back to host localhost
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  /// Cloud API endpoint for production
  static const String productionBaseUrl = 'https://taskflow-nestjs-api.onrender.com/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
