import 'package:flutter/material.dart';

class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      clipBehavior: .antiAlias,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          for (final String suggestion in suggestions)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(suggestion),
              onTap: () => onSelected(suggestion),
            ),
        ],
      ),
    );
  }
}
