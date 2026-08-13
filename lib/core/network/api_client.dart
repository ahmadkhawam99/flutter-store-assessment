import 'package:dio/dio.dart';

import '../config/api_constants.dart';
import '../error/exceptions.dart';

abstract final class ApiClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(_ExceptionInterceptor());
    return dio;
  }
}

final class _ExceptionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(err.copyWith(error: _mapException(err)));
  }

  AppException _mapException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final message = _responseMessage(exception.response?.data);

    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const NetworkException();
    }

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException(message ?? 'The request is not authorized.');
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ValidationException(
        message ?? 'The request could not be processed.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null) {
      return ServerException(
        message ?? 'The server could not complete the request.',
        statusCode: statusCode,
      );
    }

    return UnknownException(
      exception.message ?? 'An unexpected error occurred.',
    );
  }

  String? _responseMessage(Object? data) {
    if (data case {'message': final String message}) {
      return message;
    }
    return null;
  }
}
