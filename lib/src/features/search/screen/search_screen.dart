import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../bloc/search_bloc.dart';
import 'search_content.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => SearchBloc(
        searchItemsUseCase: AppDi.locator<SearchItemsUseCase>(),
      ),
      child: const SearchContent(),
    );
  }
}
