import 'package:flutter/material.dart';

import '../../../domain/domain.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  final int index;

  const ItemTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: ListTileTheme.of(context).minLeadingWidth ?? 0,
        ),
        child: Text(
          '${index + 1}',
          textAlign: .center,
        ),
      ),
      title: Text(
        item.title,
        maxLines: 2,
        overflow: .ellipsis,
      ),
    );
  }
}
