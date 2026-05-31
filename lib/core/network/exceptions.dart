class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException([this.message = 'Something went wrong', this.prefix, this.statusCode]);

  @override
  String toString() {
    return "${prefix ?? ''}$message";
  }
}

class NetworkException extends AppException {
  NetworkException([String message = 'No Internet connection'])
      : super(message, 'Network Error: ');
}

class RequestTimeoutException extends AppException {
  RequestTimeoutException([String message = 'Connection timeout'])
      : super(message, 'Timeout: ');
}

class ServerException extends AppException {
  ServerException([String message = 'Internal Server Error', int? statusCode])
      : super(message, 'Server Error: ', statusCode);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized access'])
      : super(message, 'Unauthorized: ', 401);
}

class BadRequestException extends AppException {
  BadRequestException([String message = 'Invalid request', int? statusCode])
      : super(message, 'Bad Request: ', statusCode);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found', int? statusCode])
      : super(message, 'Not Found: ', statusCode);
}

/// Thrown when API returns {success: false, message: ...}
class ApiErrorException extends AppException {
  ApiErrorException(String message) : super(message, '', 400);
}
