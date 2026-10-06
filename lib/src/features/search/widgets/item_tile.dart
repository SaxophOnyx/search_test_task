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
      leading: Text('$index'),
      title: Text(item.title),
    );
  }
}
