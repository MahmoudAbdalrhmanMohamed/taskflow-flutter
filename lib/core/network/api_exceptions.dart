import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network or server status.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final data = response.data;
          String msg = 'An unexpected server error occurred.';
          if (data is Map && data.containsKey('message')) {
            final rawMsg = data['message'];
            if (rawMsg is List) {
              msg = rawMsg.join(', ');
            } else if (rawMsg is String) {
              msg = rawMsg;
            }
          }
          return ApiException(
            message: msg,
            statusCode: response.statusCode,
            data: data,
          );
        }
        return ApiException(message: 'Invalid response from server.');
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Cannot connect to server. Ensure backend is running.',
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unknown network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}
