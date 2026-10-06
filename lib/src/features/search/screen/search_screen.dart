import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../bloc/search_bloc.dart';
import 'search_content.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => SearchBloc(
        // TODO: Implement DI
        searchItemsUseCase: SearchItemsUseCase(
          itemRepository: ItemRepositoryImpl(
            itemProvider: ItemProvider(),
          ),
        ),
      ),
      child: const SearchContent(),
    );
  }
}
