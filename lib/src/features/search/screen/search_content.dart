import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../bloc/search_bloc.dart';
import '../mappers/search_exception_mapper.dart';
import '../widgets/error_tile.dart';
import '../widgets/item_tile.dart';
import '../widgets/loading_tile.dart';
import '../widgets/search_field.dart';
import '../widgets/status_sliver.dart';

class SearchContent extends StatefulWidget {
  const SearchContent({super.key});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  static const double _loadMoreThreshold = 200;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<SearchBloc>().add(const LoadNextPage());
    }
  }

  void _onInputChanged(String value) {
    context.read<SearchBloc>().add(UpdateSuggestions(input: value));
  }

  void _onSearch(String value) {
    context.read<SearchBloc>().add(UpdateSearchString(searchString: value));
  }

  void _onRetry() {
    context.read<SearchBloc>().add(const RetrySearch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        keyboardDismissBehavior: .onDrag,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: BlocSelector<SearchBloc, SearchState, List<String>>(
              selector: (SearchState state) => state.suggestions,
              builder: (BuildContext context, List<String> suggestions) {
                return SearchField(
                  suggestions: suggestions,
                  onChanged: _onInputChanged,
                  onSearch: _onSearch,
                );
              },
            ),
          ),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (BuildContext context, SearchState state) {
              final AppException? exception = state.exception;
              final String? errorMessage = exception == null
                  ? null
                  : SearchExceptionMapper.toMessage(exception);

              if (state.items.isEmpty) {
                if (state.status == SearchStatus.loading) {
                  return const StatusSliver.loading();
                }

                return StatusSliver.message(
                  message: switch (state) {
                    _ when errorMessage != null => errorMessage,
                    SearchState(query: '') => 'Type to search',
                    _ => 'No items found',
                  },
                  onPressed: errorMessage != null ? _onRetry : null,
                );
              }

              final bool showFooter =
                  errorMessage != null ||
                  state.status == SearchStatus.loadingMore;

              return SliverList.separated(
                itemCount: state.items.length + (showFooter ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.items.length) {
                    return errorMessage != null
                        ? ErrorTile(message: errorMessage, onRetry: _onRetry)
                        : const LoadingTile();
                  }

                  return ItemTile(item: state.items[index], index: index);
                },
                separatorBuilder: (_, _) => const Divider(),
              );
            },
          ),
        ],
      ),
    );
  }
}
