import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/domain.dart';
import '../bloc/search_bloc.dart';

class SearchContent extends StatefulWidget {
  const SearchContent({super.key});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const double _loadMoreThreshold = 200;

  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      context.read<SearchBloc>().add(UpdateSearchString(searchString: value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: TextField(
              onChanged: _onSearchChanged,
              textInputAction: .search,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (BuildContext context, SearchState state) {
              if (state.isLoading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final bool showFooter = state.isLoadingMore || state.hasError;

              return SliverList.separated(
                itemCount: state.items.length + (showFooter ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.items.length) {
                    return state.hasError
                        ? ListTile(
                            title: const Text('Something went wrong'),
                            trailing: TextButton(
                              onPressed: () => context.read<SearchBloc>().add(
                                const RetrySearch(),
                              ),
                              child: const Text('Retry'),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                  }

                  final Item item = state.items[index];
                  return ListTile(
                    leading: Text('$index'),
                    title: Text(item.title),
                  );
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
