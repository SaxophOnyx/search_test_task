import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/di/domain_di.dart';

final class ModuleDi {
  const ModuleDi._();

  static void initialize(GetIt locator) {
    DataDi.initDependencies(locator);
    DomainDi.initDependencies(locator);
  }
}
