import 'dart:async';

import 'package:flutter/material.dart';

import 'suggestion_list.dart';

class SearchField extends StatefulWidget {
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSearch;
  final Duration debounceDuration;

  const SearchField({
    super.key,
    required this.suggestions,
    required this.onChanged,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  void _onChanged(String value) {
    widget.onChanged(value);

    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () => widget.onSearch(value));
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    widget.onSearch(value);
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion,
      selection: .collapsed(offset: suggestion.length),
    );
    _debounce?.cancel();
    widget.onChanged(suggestion);
    widget.onSearch(suggestion);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: OverlayPortal(
            controller: _overlayController,
            overlayChildBuilder: (BuildContext context) {
              if (widget.suggestions.isEmpty) {
                return const SizedBox.shrink();
              }

              return Align(
                alignment: .topLeft,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  targetAnchor: .bottomLeft,
                  child: TextFieldTapRegion(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: SuggestionList(
                        suggestions: widget.suggestions,
                        onSelected: _onSuggestionSelected,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onChanged,
              onSubmitted: _onSubmitted,
              onTapOutside: (_) => _focusNode.unfocus(),
              textInputAction: .search,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
