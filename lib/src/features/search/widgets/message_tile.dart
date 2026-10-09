import 'package:flutter/material.dart';

import '../../../shared_ui/shared_ui.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MessageTile({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onRetry = this.onRetry;
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: <Widget>[
            Text(
              message,
              textAlign: .center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(context.l10n.retryButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
