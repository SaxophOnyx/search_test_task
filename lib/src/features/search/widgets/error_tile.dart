import 'package:flutter/material.dart';

class ErrorTile extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorTile({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Something went wrong'),
      trailing: TextButton(
        onPressed: onRetry,
        child: const Text('Retry'),
      ),
    );
  }
}
