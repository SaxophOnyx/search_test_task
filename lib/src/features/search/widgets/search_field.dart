import 'package:flutter/material.dart';

import '../../../shared_ui/shared_ui.dart';
import 'suggestion_list.dart';

class SearchField extends StatefulWidget {
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const SearchField({
    super.key,
    required this.suggestions,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
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

  void _onSuggestionSelected(String suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion,
      selection: .collapsed(offset: suggestion.length),
    );
    widget.onSubmitted(suggestion);
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
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTapOutside: (_) => _focusNode.unfocus(),
              textInputAction: .search,
              decoration: InputDecoration(
                hintText: context.l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        );
      },
    );
  }
}
