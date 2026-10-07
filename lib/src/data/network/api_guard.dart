import 'package:dio/dio.dart';

import '../../core/core.dart';
import '../../domain/domain.dart';

final class ApiGuard {
  static const int _tooManyRequests = 429;

  const new();

  Future<T> run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(_toAppException(error), stackTrace);
    }
  }

  AppException _toAppException(Object error) {
    return switch (error) {
      DioException(
        response: Response<dynamic>(statusCode: _tooManyRequests),
      ) =>
        const LimitReachedException(),
      DioException(error: TypeError()) => const UnknownException(),
      DioException() => const FetchFailedException(),
      _ => const UnknownException(),
    };
  }
}
