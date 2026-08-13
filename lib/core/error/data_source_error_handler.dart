import 'exceptions.dart';
import 'failures.dart';

abstract final class DataSourceErrorHandler {
  static Failure handle(AppException exception) => switch (exception) {
    NetworkException() => NetworkFailure(exception.message),
    UnauthorizedException() => UnauthorizedFailure(exception.message),
    ValidationException() => ValidationFailure(exception.message),
    ServerException() => ServerFailure(exception.message),
    UnknownException() => UnknownFailure(exception.message),
  };
}
