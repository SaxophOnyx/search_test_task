import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../domain/domain.dart';
import '../data.dart';

final class DataDi {
  const DataDi._();

  static void initDependencies(GetIt locator) {
    _initNetwork(locator);
    _initProviders(locator);
    _initRepositories(locator);
  }

  static void _initNetwork(GetIt locator) {
    locator.registerLazySingleton<Dio>(() {
      final Dio dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (kDebugMode) {
        dio.interceptors.add(LogInterceptor());
      }
      return dio;
    });

    locator.registerLazySingleton<ApiGuard>(() => const ApiGuard());
  }

  static void _initProviders(GetIt locator) {
    locator.registerLazySingleton<ItemProvider>(
      () => ItemProvider(
        dio: locator<Dio>(),
        guard: locator<ApiGuard>(),
      ),
    );
  }

  static void _initRepositories(GetIt locator) {
    locator.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(
        itemProvider: locator<ItemProvider>(),
      ),
    );
  }
}
