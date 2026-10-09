import 'package:flutter/material.dart';

import 'src/core/core.dart';
import 'src/module_di.dart';
import 'src/search_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ModuleDi.initialize(DiAccess.locator);
  runApp(const SearchApp());
}
