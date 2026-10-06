import 'package:flutter/material.dart';

import 'src/core/core.dart';
import 'src/data/data.dart';
import 'src/domain/domain.dart';
import 'src/search_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DataDi.initDependencies(AppDi.locator);
  DomainDi.initDependencies(AppDi.locator);

  runApp(const SearchApp());
}
