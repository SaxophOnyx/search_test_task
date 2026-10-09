import 'package:flutter/material.dart';

import 'message_tile.dart';

class StatusSliver extends StatelessWidget {
  final String? message;
  final VoidCallback? onPressed;

  const StatusSliver.loading({super.key}) : message = null, onPressed = null;

  const StatusSliver.message({
    super.key,
    required String this.message,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String? message = this.message;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: message == null
          ? const Center(child: CircularProgressIndicator())
          : MessageTile(message: message, onRetry: onPressed),
    );
  }
}
