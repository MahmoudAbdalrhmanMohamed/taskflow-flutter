class AppConfig {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  /// Default API base URL points to the live Cloud API connected to Neon PostgreSQL
  static String get defaultBaseUrl {
    return productionBaseUrl;
  }

  /// Cloud API endpoint for production (Neon PostgreSQL + Vercel Serverless)
  static const String productionBaseUrl =
      'https://taskflow-nestjs-api.vercel.app/api';

  /// Local API endpoint for offline/local development
  static const String localBaseUrl = 'http://localhost:3001/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
