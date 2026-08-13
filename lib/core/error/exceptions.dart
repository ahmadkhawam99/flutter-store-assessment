sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Unable to connect to the server.']);
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'The request is not authorized.',
    int statusCode = 401,
  ]) : super(statusCode: statusCode);
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode});
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
