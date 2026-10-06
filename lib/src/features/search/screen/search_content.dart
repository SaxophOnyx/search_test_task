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

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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

              return SliverList.separated(
                itemCount: state.items.length,
                itemBuilder: (BuildContext context, int index) {
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
