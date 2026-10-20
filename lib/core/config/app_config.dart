class AppConfig {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  /// Default API base URL points to local backend connected to Neon
  static String get defaultBaseUrl {
    return localBaseUrl;
  }

  /// Local API endpoint connected to Neon PostgreSQL
  static const String localBaseUrl = 'http://localhost:3001/api';

  /// Cloud API endpoint for production
  static const String productionBaseUrl = 'https://taskflow-nestjs-api.vercel.app/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
