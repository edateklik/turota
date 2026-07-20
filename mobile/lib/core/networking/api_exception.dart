class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.errorCode,
    required this.message,
    required this.traceId,
  });

  factory ApiException.fromJson(int statusCode, Map<String, dynamic> json) {
    return ApiException(
      statusCode: statusCode,
      errorCode: json['errorCode'] as String? ?? 'UNKNOWN_ERROR',
      message:
          json['detail'] as String? ??
          json['title'] as String? ??
          'Bilinmeyen bir hata oluştu.',
      traceId: json['traceId'] as String? ?? '',
    );
  }

  final int statusCode;
  final String errorCode;
  final String message;
  final String traceId;

  bool get isConflict =>
      statusCode == 409 || errorCode == 'EMAIL_ALREADY_EXISTS';
  bool get isUnauthorized =>
      statusCode == 401 || errorCode == 'INVALID_CREDENTIALS';
  bool get isValidationError =>
      statusCode == 400 || errorCode == 'VALIDATION_ERROR';

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, errorCode: $errorCode, message: $message)';
}
