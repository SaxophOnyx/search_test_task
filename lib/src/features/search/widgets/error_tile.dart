import 'package:flutter/material.dart';

import '../../../shared_ui/shared_ui.dart';

class ErrorTile extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorTile({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message),
      trailing: TextButton(
        onPressed: onRetry,
        child: Text(context.l10n.retryButton),
      ),
    );
  }
}
