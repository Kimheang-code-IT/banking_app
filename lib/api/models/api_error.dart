/// API Error model
/// 
/// Represents different types of API errors
class ApiError {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      errorCode: json['errorCode'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'errorCode': errorCode,
      'details': details,
    };
  }

  @override
  String toString() => message;
}

/// Common API Error Types
class ApiErrorTypes {
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String serverError = 'SERVER_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
}

