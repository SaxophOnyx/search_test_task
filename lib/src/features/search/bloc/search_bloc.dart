import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchItemsUseCase _searchItemsUseCase;

  SearchBloc({
    required SearchItemsUseCase searchItemsUseCase,
  }) : _searchItemsUseCase = searchItemsUseCase,
       super(const SearchState.initial()) {
    on<UpdateSearchString>(_onUpdateSearchString, transformer: restartable());
  }

  Future<void> _onUpdateSearchString(
    UpdateSearchString event,
    Emitter<SearchState> emit,
  ) async {
    final String query = event.searchString.trim();

    if (query.isEmpty) {
      emit(const SearchState.initial());
      return;
    }

    emit(state.copyWith(isLoading: true));

    final List<Item> items = await _searchItemsUseCase.execute(
      SearchItemsParams(name: query, from: 0),
    );

    emit(state.copyWith(items: items, isLoading: false));
  }
}
