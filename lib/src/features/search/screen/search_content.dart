import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
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

  void _onSearchChanged(String value) {
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
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: SearchField(onChanged: _onSearchChanged),
          ),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (BuildContext context, SearchState state) {
              if (state.items.isEmpty) {
                if (state.isLoading) {
                  return const StatusSliver.loading();
                }

                return StatusSliver.message(
                  message: switch (state) {
                    SearchState(hasError: true) => 'Something went wrong',
                    SearchState(query: '') => 'Type to search',
                    _ => 'No items found',
                  },
                  onPressed: state.hasError ? _onRetry : null,
                );
              }

              final bool showFooter = state.isLoadingMore || state.hasError;

              return SliverList.separated(
                itemCount: state.items.length + (showFooter ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.items.length) {
                    return state.hasError ? ErrorTile(onRetry: _onRetry) : const LoadingTile();
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
