import 'package:get_it/get_it.dart';

import '../../domain/domain.dart';
import '../data.dart';

final class DataDi {
  const DataDi._();

  static void initDependencies(GetIt locator) {
    _initProviders(locator);
    _initRepositories(locator);
  }

  static void _initProviders(GetIt locator) {
    locator.registerLazySingleton<ItemProvider>(ItemProvider.new);
  }

  static void _initRepositories(GetIt locator) {
    locator.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(
        itemProvider: locator<ItemProvider>(),
      ),
    );
  }
}
