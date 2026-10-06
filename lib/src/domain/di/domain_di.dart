import 'package:get_it/get_it.dart';

import '../domain.dart';

final class DomainDi {
  const DomainDi._();

  static void initDependencies(GetIt locator) {
    _initUseCases(locator);
  }

  static void _initUseCases(GetIt locator) {
    locator.registerLazySingleton<SearchItemsUseCase>(
      () => SearchItemsUseCase(
        itemRepository: locator<ItemRepository>(),
      ),
    );
  }
}
